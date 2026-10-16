import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:camso_mobile/core/api/api_client.dart';
import 'package:camso_mobile/core/download/document_download_service.dart';
import 'package:camso_mobile/data/mock_data.dart';
import 'package:camso_mobile/models/document.dart';
import 'package:camso_mobile/repositories/document_repository.dart';
import 'package:camso_mobile/repositories/product_repository.dart';
import 'package:camso_mobile/screens/document_detail_screen.dart';
import 'package:camso_mobile/screens/product_detail_screen.dart';
import 'package:camso_mobile/screens/product_updates_screen.dart';
import 'package:camso_mobile/state/app_state.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late ApiClient apiClient;
  late DocumentRepository docRepo;
  late ProductRepository productRepo;
  late Directory tempDir;

  // Real backend CUID constants
  const xtr770ProductId = 'cmv6j48qd0045ufj88qjrshv8';
  const xtr770DocId = 'cmv9jodyx0000uffkydy4c8ij';
  const xtr770Pid = 'XTR770-12-16.5';

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    apiClient = ApiClient();
    docRepo = DocumentRepository(apiClient: apiClient);
    productRepo = ProductRepository(apiClient: apiClient);
    tempDir = Directory.systemTemp.createTempSync('camso_test_downloads_');
    DocumentDownloadService().setDestinationDirectoryForTesting(tempDir);
  });

  tearDown(() {
    apiClient.resetClient();
    apiClient.setAuthToken(null);
    DocumentDownloadService().resetClient();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Task 1: CUID Validation & Mock Data Consistency', () {
    test('XTR 770 mock product uses authentic backend CUID and PID', () {
      final xtr = products.firstWhere((p) => p.pid == xtr770Pid);
      expect(xtr.id, xtr770ProductId);
      expect(xtr.name, contains('XTR 770'));
    });

    test('XTR 770 mock document uses authentic backend CUID and points to product CUID', () {
      final doc = documents.firstWhere((d) => d.id == xtr770DocId);
      expect(doc.id, xtr770DocId);
      expect(doc.productId, xtr770ProductId);
      expect(doc.title, contains('XTR 770'));
      expect(doc.filename, 'xtr_770_datasheet.pdf');
      expect(doc.hasFile, isTrue);
    });

    test('Document model parses authentic Prisma backend json with filename and fileSizeBytes', () {
      final rawJson = {
        'id': xtr770DocId,
        'title': 'CAMSO XTR 770 Product Data Sheet',
        'type': 'DATASHEET',
        'document_type': 'DATASHEET',
        'access_level': 'PUBLIC',
        'category': 'Tracks',
        'description': 'Product specification sheet for XTR 770 track.',
        'product_id': xtr770ProductId,
        'file_url': 'https://camso-backend.onrender.com/storage/xtr_770.pdf',
        'file_name': 'xtr_770_datasheet.pdf',
        'file_size_bytes': 148520,
        'created_at': '2026-03-01T12:00:00.000Z',
      };

      final doc = Document.fromJson(rawJson);
      expect(doc.id, xtr770DocId);
      expect(doc.productId, xtr770ProductId);
      expect(doc.filename, 'xtr_770_datasheet.pdf');
      expect(doc.fileSizeBytes, 148520);
      expect(doc.fileSize, contains('KB'));
      expect(doc.hasFile, isTrue);
    });

    test('getDownloadInfo calls GET /api/v1/documents/:id/download with real CUID', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/documents/$xtr770DocId/download');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'documentId': xtr770DocId,
              'download_url': 'https://supabase.co/storage/v1/object/sign/docs/xtr770.pdf?token=abc',
              'file_name': 'xtr_770_datasheet.pdf',
              'mime_type': 'application/pdf',
              'file_size_bytes': 148520,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final info = await docRepo.getDownloadInfo(xtr770DocId);
      expect(info.documentId, xtr770DocId);
      expect(info.downloadUrl, contains('supabase.co'));
      expect(info.fileName, 'xtr_770_datasheet.pdf');
      expect(info.fileSizeBytes, 148520);
    });

    test('getDownloadInfo throws DocumentException when server returns 422 for invalid short ID', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/documents/d007/download');
        return http.Response(
          jsonEncode({
            'type': 'VALIDATION_ERROR',
            'message': 'Invalid document ID',
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      }));

      expect(
        () => docRepo.getDownloadInfo('d007'),
        throwsA(predicate((e) => e is DocumentException && e.statusCode == 422 && e.message.contains('Invalid document ID'))),
      );
    });
  });

  group('Task 2: DocumentDownloadService & %PDF Magic Byte Validation', () {
    test('verifyPdfSignature identifies valid %PDF header', () {
      final validPdf = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x35]; // %PDF-1.5
      expect(DocumentDownloadService.verifyPdfSignature(validPdf), isTrue);
    });

    test('verifyPdfSignature rejects HTML, JSON, and truncated payloads', () {
      final html = utf8.encode('<!DOCTYPE html><html><body>Error</body></html>');
      final json = utf8.encode('{"error": "Unauthorized"}');
      final shortBytes = [0x25, 0x50]; // only %P

      expect(DocumentDownloadService.verifyPdfSignature(html), isFalse);
      expect(DocumentDownloadService.verifyPdfSignature(json), isFalse);
      expect(DocumentDownloadService.verifyPdfSignature(shortBytes), isFalse);
      expect(DocumentDownloadService.verifyPdfSignature([]), isFalse);
    });

    test('sanitizeFileName sanitizes invalid characters and ensures .pdf extension', () {
      expect(DocumentDownloadService.sanitizeFileName('XTR:770/Spec*Sheet?.pdf'), 'XTR_770_Spec_Sheet_.pdf');
      expect(DocumentDownloadService.sanitizeFileName('My Document'), 'My Document.pdf');
      expect(DocumentDownloadService.sanitizeFileName('   '), 'camso_document.pdf');
    });

    test('downloadAndSave downloads valid PDF, saves to disk, and verifies non-zero length', () async {
      final mockPdfBytes = [
        0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34, // %PDF-1.4
        ...List.filled(1024, 0x20),
      ];

      final downloadService = DocumentDownloadService();
      downloadService.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://download.camso.test/xtr_770.pdf');
        return http.Response.bytes(
          mockPdfBytes,
          200,
          headers: {'content-type': 'application/pdf'},
        );
      }));

      final result = await downloadService.downloadAndSave(
        downloadUrl: 'https://download.camso.test/xtr_770.pdf',
        preferredFileName: 'xtr_770_datasheet.pdf',
      );

      expect(result.isSuccess, isTrue);
      expect(result.isPdf, isTrue);
      expect(result.fileSizeBytes, mockPdfBytes.length);
      expect(result.filePath, isNotNull);
      expect(result.displayLocation, contains(tempDir.path));

      // Verify file actually exists and contains the magic bytes
      final savedFile = File(result.filePath!);
      expect(savedFile.existsSync(), isTrue);
      expect(savedFile.lengthSync(), mockPdfBytes.length);
      final readBytes = savedFile.readAsBytesSync();
      expect(readBytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });

    test('downloadAndSave fails when endpoint returns HTML error instead of PDF', () async {
      final htmlError = utf8.encode('<html><body>404 Not Found in Storage</body></html>');

      final downloadService = DocumentDownloadService();
      downloadService.setClientForTesting(MockHttpClient((request) async {
        return http.Response.bytes(htmlError, 200, headers: {'content-type': 'text/html'});
      }));

      final result = await downloadService.downloadAndSave(
        downloadUrl: 'https://download.camso.test/corrupted.pdf',
        preferredFileName: 'corrupted.pdf',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('not a valid PDF'));
    });

    test('downloadAndSave handles HTTP 403 / 500 error without throwing', () async {
      final downloadService = DocumentDownloadService();
      downloadService.setClientForTesting(MockHttpClient((request) async {
        return http.Response('Forbidden', 403);
      }));

      final result = await downloadService.downloadAndSave(
        downloadUrl: 'https://download.camso.test/forbidden.pdf',
        preferredFileName: 'forbidden.pdf',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('HTTP 403'));
    });
  });

  group('Task 3: Both Navigation Paths Resolve Real Products & Documents', () {
    final xtrProduct = products.firstWhere((p) => p.pid == xtr770Pid);
    final xtrDoc = documents.firstWhere((d) => d.id == xtr770DocId);

    testWidgets('Path A: Home -> Products -> ProductDetailScreen fetches documents by product CUID', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/products/$xtr770ProductId') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': xtrProduct.id,
                'pid': xtrProduct.pid,
                'name': xtrProduct.name,
                'slug': 'xtr-770',
                'description': xtrProduct.description,
                'category': {'name': 'Tracks'},
                'images': [],
                'specifications': [],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/documents') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': xtrDoc.id,
                  'title': xtrDoc.title,
                  'type': xtrDoc.type,
                  'product_id': xtrProduct.id,
                  'file_url': 'https://camso-backend.onrender.com/storage/xtr_770.pdf',
                  'file_name': xtrDoc.filename,
                  'file_size_bytes': 148520,
                  'access_level': 'PUBLIC',
                }
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductDetailScreen(
              product: xtrProduct,
              repository: productRepo,
              documentRepository: docRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify product detail loaded
      expect(find.text(xtrProduct.name), findsWidgets);

      // Tap on Tab 3: Documents
      final documentsTab = find.text('Documents');
      expect(documentsTab, findsOneWidget);
      await tester.tap(documentsTab);
      await tester.pumpAndSettle();

      // Verify document card is rendered for XTR 770 datasheet
      expect(find.text(xtrDoc.title), findsOneWidget);
    });

    testWidgets('Path B: ProductUpdatesScreen matches legacy p006 to real product and navigates to ProductDetailScreen', (tester) async {
      final appState = AppState();
      appState.productItems = [xtrProduct];

      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/products/$xtr770ProductId') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': xtrProduct.id,
                'pid': xtrProduct.pid,
                'name': xtrProduct.name,
                'slug': 'xtr-770',
                'description': xtrProduct.description,
                'category': {'name': 'Tracks'},
                'images': [],
                'specifications': [],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/documents') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': xtrDoc.id,
                  'title': xtrDoc.title,
                  'type': xtrDoc.type,
                  'product_id': xtrProduct.id,
                  'file_url': 'https://camso-backend.onrender.com/storage/xtr_770.pdf',
                  'file_name': xtrDoc.filename,
                  'file_size_bytes': 148520,
                  'access_level': 'PUBLIC',
                }
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: ProductUpdatesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the XTR 770 update card (which originally had productId 'p006')
      final xtrUpdate = find.textContaining('XTR 770');
      expect(xtrUpdate, findsWidgets);

      // Tap the update card
      await tester.tap(xtrUpdate.first);
      await tester.pumpAndSettle();

      // Should have navigated to ProductDetailScreen for XTR 770
      expect(find.text(xtrProduct.name), findsWidgets);

      // Switch to Documents tab
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Document list displays the datasheet
      expect(find.text(xtrDoc.title), findsOneWidget);
    });
  });

  group('Task 4: ProductDetailScreen Documents Tab States', () {
    final testProduct = products.first;

    testWidgets('Shows populated list when documents exist', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'cmv_doc_01',
                'title': 'Test Data Sheet',
                'type': 'Datasheet',
                'category': 'datasheets',
                'product_id': testProduct.id,
                'file_name': 'test_sheet.pdf',
                'file_url': 'https://camso.test/sheet.pdf',
                'access_level': 'PUBLIC',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductDetailScreen(
              product: testProduct,
              repository: productRepo,
              documentRepository: docRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('Test Data Sheet'), findsOneWidget);
    });

    testWidgets('Shows empty state when no documents exist for the product', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'success': true, 'data': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductDetailScreen(
              product: testProduct,
              repository: productRepo,
              documentRepository: docRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('No documents available'), findsOneWidget);
    });

    testWidgets('Shows error state with retry button on failure, and retrying reloads', (tester) async {
      bool shouldFailDocuments = true;

      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/documents') {
          if (shouldFailDocuments) {
            return http.Response('Internal Server Error', 500);
          }
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'cmv_recovered_doc',
                  'title': 'Recovered Data Sheet',
                  'type': 'Datasheet',
                  'category': 'datasheets',
                  'product_id': testProduct.id,
                  'file_name': 'recovered.pdf',
                  'file_url': 'https://camso.test/recovered.pdf',
                  'access_level': 'PUBLIC',
                }
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': testProduct.id,
              'pid': testProduct.pid,
              'name': testProduct.name,
              'description': testProduct.description,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductDetailScreen(
              product: testProduct,
              repository: productRepo,
              documentRepository: docRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Documents failed -> Error message and Retry button visible
      expect(find.text('Could not load documents'), findsOneWidget);
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      // Now allow success on retry
      shouldFailDocuments = false;
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      // Recovered document card displayed
      expect(find.text('Recovered Data Sheet'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('Task 5: DocumentDetailScreen Download Flow & Storage Feedback', () {
    final xtrDoc = documents.firstWhere((d) => d.id == xtr770DocId);

    testWidgets('DocumentDetailScreen downloads verified PDF, updates to downloaded state, and displays honest path', (tester) async {
      final mockPdfBytes = [
        0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34, // %PDF-1.4
        ...List.filled(2048, 0xAA),
      ];

      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/documents/$xtr770DocId/download') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'documentId': xtr770DocId,
                'download_url': 'https://download.camso.test/storage/xtr_770_signed.pdf',
                'file_name': 'xtr_770_datasheet.pdf',
                'mime_type': 'application/pdf',
                'file_size_bytes': mockPdfBytes.length,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      final downloadService = DocumentDownloadService();
      downloadService.setClientForTesting(MockHttpClient((request) async {
        if (request.url.toString() == 'https://download.camso.test/storage/xtr_770_signed.pdf') {
          return http.Response.bytes(
            mockPdfBytes,
            200,
            headers: {'content-type': 'application/pdf'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: DocumentDetailScreen(
              documentId: xtr770DocId,
              document: xtrDoc,
              repository: docRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify screen renders
      expect(find.text(xtrDoc.title), findsWidgets);
      expect(find.text('DOWNLOAD DOCUMENT'), findsOneWidget);

      // Tap download button
      await tester.tap(find.text('DOWNLOAD DOCUMENT'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify button transitioned to 'DOWNLOADED' and share button appeared
      expect(find.text('DOWNLOADED'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);

      // Verify SnackBar with honest path and OPEN action
      expect(find.textContaining('Saved "xtr_770_datasheet.pdf" to'), findsOneWidget);
      expect(find.text('OPEN'), findsOneWidget);

      // Verify file was written to disk with %PDF magic bytes
      final savedFile = File('${tempDir.path}/xtr_770_datasheet.pdf');
      expect(savedFile.existsSync(), isTrue);
      expect(savedFile.lengthSync(), mockPdfBytes.length);
    });

    testWidgets('DocumentDetailScreen displays error SnackBar when download info returns 422 Invalid document ID', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'type': 'VALIDATION_ERROR',
            'message': 'Invalid document ID',
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      }));

      final docWithInvalidId = Document(
        id: 'd007',
        title: 'Legacy Sheet',
        type: 'Datasheet',
        category: 'datasheets',
        fileSize: '100 KB',
        format: 'PDF',
        date: '2026-01-01',
        version: '1.0',
        description: 'Legacy document',
        productId: 'p006',
        pages: 2,
        language: 'EN',
        isDownloaded: false,
        hasFile: true,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: DocumentDetailScreen(
              documentId: 'd007',
              document: docWithInvalidId,
              repository: docRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap DOWNLOAD DOCUMENT
      await tester.tap(find.text('DOWNLOAD DOCUMENT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // SnackBar shows error message
      expect(find.textContaining('Invalid document ID'), findsOneWidget);
      // Button still shows DOWNLOAD DOCUMENT (not downloaded)
      expect(find.text('DOWNLOAD DOCUMENT'), findsOneWidget);
    });
  });
}

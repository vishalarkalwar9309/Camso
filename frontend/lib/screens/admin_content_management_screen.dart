import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/document.dart';
import '../models/notification.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Administrative Content Management Screen.
///
/// Requirement 1: Manage products, categories, documents, notifications, and product updates.
class AdminContentManagementScreen extends StatefulWidget {
  final String section;
  const AdminContentManagementScreen({super.key, required this.section});

  @override
  State<AdminContentManagementScreen> createState() =>
      _AdminContentManagementScreenState();
}

class _AdminContentManagementScreenState
    extends State<AdminContentManagementScreen> {
  String get section => widget.section;
  bool get isProducts => section == 'Products';
  bool get isCategories => section == 'Categories';
  bool get isDocuments => section == 'Documents';
  bool get isNotifications => section == 'Notifications';
  bool get isUpdates => section == 'Product Updates';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      if (isProducts) state.refreshProducts();
      if (isCategories) state.refreshCategories();
      if (isDocuments) state.refreshDocuments();
      if (isNotifications) state.refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final count = isProducts
        ? state.productItems.length
        : isCategories
            ? state.categoryItems.length
            : isDocuments
                ? state.documentItems.length
                : isNotifications
                    ? state.notificationItems.length
                    : productUpdates.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(section.toUpperCase(),
            style: AppTypography.heading(19, color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        onPressed: () => _editItem(),
        icon: const Icon(Icons.add),
        label: Text('Add ${_singular()}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_outlined,
                    color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count ${_plural()}',
                        style: AppTypography.heading(18, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CMS Administration · Authenticated Repository Integration',
                        style: AppTypography.body(11,
                            color: Colors.white.withValues(alpha: .85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (count == 0)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No items yet. Tap Add to create one.')),
            ),
          ..._items(state).map((item) => _itemCard(item)),
        ],
      ),
    );
  }

  List<dynamic> _items(AppState state) {
    if (isProducts) return List<Product>.from(state.productItems);
    if (isCategories) return List<Map<String, dynamic>>.from(state.categoryItems);
    if (isDocuments) return List<Document>.from(state.documentItems);
    if (isNotifications) {
      return List<AppNotification>.from(state.notificationItems);
    }
    return List<Map<String, dynamic>>.from(productUpdates);
  }

  Widget _itemCard(dynamic item) {
    final title = isProducts
        ? (item as Product).name
        : isCategories
            ? (item as Map<String, dynamic>)['name']?.toString() ?? 'Category'
            : isDocuments
                ? (item as Document).title
                : isNotifications
                    ? (item as AppNotification).title
                    : (item as Map<String, dynamic>)['title']?.toString() ??
                        'Untitled';

    final subtitle = isProducts
        ? (item as Product).pid
        : isCategories
            ? 'ID: ${(item as Map<String, dynamic>)['id']} · ${item['count'] ?? 0} products'
            : isDocuments
                ? '${(item as Document).format} · ${item.category} · [${item.accessLevel.label}]'
                : isNotifications
                    ? (item as AppNotification).body
                    : (item as Map<String, dynamic>)['summary']?.toString() ?? '';

    final isRead = isNotifications
        ? (item as AppNotification).isRead
        : isUpdates
            ? (item as Map<String, dynamic>)['isRead'] == true
            : false;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                isProducts
                    ? Icons.inventory_2_outlined
                    : isCategories
                        ? Icons.category_outlined
                        : isDocuments
                            ? Icons.description_outlined
                            : isNotifications
                                ? Icons.notifications_outlined
                                : Icons.campaign_outlined,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(12, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(10, color: AppColors.muted),
                  ),
                  if (isNotifications || isUpdates)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isRead ? 'Read' : 'Unread',
                        style: AppTypography.body(10,
                            color: isRead ? AppColors.muted : AppColors.orange,
                            weight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') _editItem(item);
                if (action == 'delete') _deleteItem(item, title);
                if (action == 'toggle_read') _toggleRead(item);
              },
              itemBuilder: (_) => [
                if (isNotifications || isUpdates)
                  PopupMenuItem(
                    value: 'toggle_read',
                    child: Text(isRead ? 'Mark unread' : 'Mark read'),
                  ),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editItem([dynamic item]) async {
    final titleController = TextEditingController(
      text: item == null
          ? ''
          : isProducts
              ? (item as Product).name
              : isCategories
                  ? (item as Map<String, dynamic>)['name']?.toString() ?? ''
                  : isDocuments
                      ? (item as Document).title
                      : isNotifications
                          ? (item as AppNotification).title
                          : (item as Map<String, dynamic>)['title']
                                  ?.toString() ??
                              '',
    );

    final detailController = TextEditingController(
      text: item == null
          ? ''
          : isProducts
              ? (item as Product).description
              : isCategories
                  ? (item as Map<String, dynamic>)['id']?.toString() ?? ''
                  : isDocuments
                      ? (item as Document).description
                      : isNotifications
                          ? (item as AppNotification).body
                          : (item as Map<String, dynamic>)['summary']
                                  ?.toString() ??
                              '',
    );

    DocumentAccessLevel selectedAccess = isDocuments && item != null
        ? (item as Document).accessLevel
        : DocumentAccessLevel.public;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${item == null ? 'Add' : 'Edit'} ${_singular()}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: _titleLabel()),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailController,
                  decoration: InputDecoration(labelText: _detailLabel()),
                  maxLines: isCategories ? 1 : 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                if (isDocuments) ...[
                  const SizedBox(height: 16),
                  const Text('Access Permission Level:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<DocumentAccessLevel>(
                    initialValue: selectedAccess,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: DocumentAccessLevel.values.map((lvl) {
                      return DropdownMenuItem(
                        value: lvl,
                        child: Text(lvl.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedAccess = val);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final title = titleController.text.trim();
    final detail = detailController.text.trim();
    titleController.dispose();
    detailController.dispose();

    if (title.isEmpty || detail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    if (!mounted) return;
    final appState = context.read<AppState>();

    if (isProducts) {
      if (item == null) {
        final template = appState.productItems.isNotEmpty
            ? appState.productItems.first
            : products.first;
        final newProduct = Product(
          id: '',
          name: title,
          pid: 'DEMO-${DateTime.now().millisecondsSinceEpoch % 100000}',
          category: template.category,
          categoryName: template.categoryName,
          size: template.size,
          plyRating: template.plyRating,
          treadDepth: template.treadDepth,
          loadIndex: template.loadIndex,
          maxLoad: template.maxLoad,
          maxSpeed: template.maxSpeed,
          description: detail,
          features: List<String>.from(template.features),
          applications: List<String>.from(template.applications),
          compatibleEquipment: List<String>.from(template.compatibleEquipment),
          specifications: Map<String, String>.from(template.specifications),
          image: template.image,
          isNew: true,
          isFeatured: false,
          rating: 4.8,
          reviewCount: 1,
        );
        try {
          await appState.addProduct(newProduct);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating product: $e')),
            );
          }
          return;
        }
      } else {
        final old = item as Product;
        try {
          await appState.updateProduct(old.copyWith(
            name: title,
            description: detail,
          ));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating product: $e')),
            );
          }
          return;
        }
      }
    } else if (isCategories) {
      if (item == null) {
        final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
        final cat = {
          'name': title,
          'slug': slug.isNotEmpty ? slug : 'cat-${DateTime.now().millisecondsSinceEpoch}',
          'description': detail,
          'icon_url': image1,
          'banner_url': image1,
          'is_active': true,
        };
        try {
          await appState.addCategory(cat);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating category: $e')),
            );
          }
          return;
        }
      } else {
        final old = item as Map<String, dynamic>;
        final catId = old['id'].toString();
        try {
          await appState.updateCategory(catId, {
            'name': title,
            'description': detail,
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating category: $e')),
            );
          }
          return;
        }
      }
    } else if (isDocuments) {
      if (item == null) {
        final template = appState.documentItems.isNotEmpty
            ? appState.documentItems.first
            : documents.first;
        final doc = Document(
          id: '',
          title: title,
          type: template.type,
          category: template.category,
          fileSize: template.fileSize,
          format: template.format,
          date: DateTime.now().toIso8601String().substring(0, 10),
          version: '1.0',
          description: detail,
          productId: template.productId,
          pages: template.pages,
          language: template.language,
          isDownloaded: false,
          accessLevel: selectedAccess,
        );
        try {
          await appState.addDocument(doc);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating document: $e')),
            );
          }
          return;
        }
      } else {
        final old = item as Document;
        try {
          await appState.updateDocument(old.copyWith(
            title: title,
            description: detail,
            accessLevel: selectedAccess,
          ));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating document: $e')),
            );
          }
          return;
        }
      }
    } else if (isNotifications) {
      if (item == null) {
        try {
          await appState.addNotification(AppNotification(
            id: '',
            type: 'PRODUCT',
            title: title,
            body: detail,
            date: DateTime.now().toIso8601String(),
            isRead: false,
            icon: 'info',
          ));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating notification: $e')),
            );
          }
          return;
        }
      } else {
        final old = item as AppNotification;
        try {
          await appState.updateNotification(old.copyWith(
            title: title,
            body: detail,
          ));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating notification: $e')),
            );
          }
          return;
        }
      }
    } else {
      final now = DateTime.now();
      if (item == null) {
        final update = {
          'id': 'update_${now.millisecondsSinceEpoch}',
          'type': 'updated',
          'title': title,
          'summary': detail,
          'date': now.toIso8601String().substring(0, 10),
          'productId': null,
          'isRead': false,
          'tag': 'Admin Update',
          'tagColor': '#203F99',
          'image': null,
        };
        try {
          await appState.notificationRepository.addProductUpdate(update);
          productUpdates.insert(0, update);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating product update: $e')),
            );
          }
          return;
        }
      } else {
        final old = item as Map<String, dynamic>;
        final index = productUpdates.indexWhere((u) => u['id'] == old['id']);
        if (index >= 0) {
          final updated = {...old, 'title': title, 'summary': detail};
          try {
            await appState.notificationRepository.updateProductUpdate(updated);
            productUpdates[index] = updated;
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating product update: $e')),
              );
            }
            return;
          }
        }
      }
    }

    appState.notifyMockDataChanged();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_singular()} saved successfully.')),
      );
    }
  }

  Future<void> _deleteItem(dynamic item, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${_singular()}?'),
        content: Text('Delete "$title" from the catalogue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!mounted) return;
    final appState = context.read<AppState>();

    try {
      if (isProducts) {
        await appState.removeProduct((item as Product).id);
      } else if (isCategories) {
        final catId = (item as Map<String, dynamic>)['id'].toString();
        await appState.removeCategory(catId);
      } else if (isDocuments) {
        await appState.removeDocument((item as Document).id);
      } else if (isNotifications) {
        await appState.removeNotification((item as AppNotification).id);
      } else {
        final updateId = (item as Map<String, dynamic>)['id'].toString();
        await appState.notificationRepository.deleteProductUpdate(updateId);
        productUpdates.removeWhere((u) => u['id'] == updateId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action could not be completed: $e'),
            backgroundColor: AppColors.blue,
          ),
        );
      }
      return;
    }

    appState.notifyMockDataChanged();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_singular()} deleted successfully.')),
      );
    }
  }

  void _toggleRead(dynamic item) {
    final appState = context.read<AppState>();
    if (isNotifications) {
      final old = item as AppNotification;
      appState.replaceNotification(
        old.id,
        old.copyWith(isRead: !old.isRead),
      );
    } else if (isUpdates) {
      final old = item as Map<String, dynamic>;
      final index = productUpdates.indexWhere((u) => u['id'] == old['id']);
      if (index >= 0) {
        productUpdates[index]['isRead'] = !(old['isRead'] == true);
      }
      appState.notifyMockDataChanged();
    }
    setState(() {});
  }

  String _singular() => isProducts
      ? 'product'
      : isCategories
          ? 'category'
          : isDocuments
              ? 'document'
              : isNotifications
                  ? 'notification'
                  : 'product update';

  String _plural() => isProducts
      ? 'products'
      : isCategories
          ? 'categories'
          : isDocuments
              ? 'documents'
              : isNotifications
                  ? 'notifications'
                  : 'product updates';

  String _titleLabel() => isProducts
      ? 'Product name'
      : isCategories
          ? 'Category name'
          : isDocuments
              ? 'Document title'
              : isNotifications
                  ? 'Notification title'
                  : 'Update title';

  String _detailLabel() => isProducts
      ? 'Description'
      : isCategories
          ? 'Category identifier / slug'
          : isDocuments
              ? 'Document description'
              : 'Message summary';
}

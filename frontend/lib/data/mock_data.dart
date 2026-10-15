import '../models/document.dart';
import '../models/faq_item.dart';
import '../models/notification.dart';
import '../models/product.dart';
import '../models/testimonial.dart';

final productUpdates = [
  {
    'id': 'u001',
    'type': 'new',
    'title': 'Introducing XTR 770 Extreme Terrain Tire',
    'summary':
        'New skid steer tire engineered for the harshest quarry and demolition environments with maximum puncture resistance.',
    'date': '2024-11-20',
    'productId': 'p006',
    'isRead': false,
    'tag': 'New Product',
    'tagColor': '#203F99',
    'image': image6,
  },
  {
    'id': 'u002',
    'type': 'updated',
    'title': 'CTL 400 Series: Enhanced Steel Cord Design',
    'summary':
        'Updated triple-strand steel cord reinforcement in CTL 400 tracks provides 15% longer service life. All new orders ship with updated spec.',
    'date': '2024-11-10',
    'productId': 'p003',
    'isRead': false,
    'tag': 'Updated',
    'tagColor': '#F5822D',
    'image': image3,
  },
  {
    'id': 'u003',
    'type': 'updated',
    'title': 'SKS S1 Tread Compound Upgrade',
    'summary':
        'Enhanced cut-and-chip resistant compound formulated for the SKS S1 line. Improves wear life by up to 20% on mixed abrasive surfaces.',
    'date': '2024-10-28',
    'productId': 'p001',
    'isRead': false,
    'tag': 'Updated',
    'tagColor': '#F5822D',
    'image': image1,
  },
  {
    'id': 'u004',
    'type': 'promotion',
    'title': 'Winter Fleet Readiness Program 2024–25',
    'summary':
        'Special fleet pricing on skid steer tires and rubber tracks through authorized dealers until December 31, 2024.',
    'date': '2024-11-05',
    'productId': null,
    'isRead': true,
    'tag': 'Promotion',
    'tagColor': '#059669',
    'image': image2,
  },
  {
    'id': 'u005',
    'type': 'new',
    'title': 'TLH 260: New Entry-Level Telehandler Tire',
    'summary':
        'Affordable radial option for standard material handling applications. Available from stock at all authorized distributors.',
    'date': '2024-10-15',
    'productId': 'p008',
    'isRead': true,
    'tag': 'New Product',
    'tagColor': '#203F99',
    'image': image2,
  },
];

const testimonials = [
  Testimonial(
    id: 't001',
    type: 'Customer Story',
    title: 'SKS S1 Delivers 40% Longer Service Life at Schmidt Demolition',
    company: 'Schmidt Demolition GmbH',
    location: 'Munich, Germany',
    contact: 'Klaus Schmidt, Operations Manager',
    avatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format',
    coverImage:
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=350&fit=crop&auto=format',
    excerpt:
        'After switching to CAMSO SKS S1 tires, our fleet saw a dramatic 40% increase in service life and 65% less tire-related downtime.',
    content:
        'Schmidt Demolition has been operating heavy demolition projects across Bavaria for over 20 years. When tire costs became a significant operational concern, our fleet manager began evaluating premium alternatives.\n\n'
        'After a 6-month trial with CAMSO SKS S1 tires on our Bobcat S650 fleet, the results were undeniable. We recorded a 40% increase in service life compared to our previous tires, and tire-related downtime dropped by 65%. The reinforced sidewalls handled the sharp debris from demolition work that had previously been our biggest challenge.\n\n'
        '"The cost per operating hour has been significantly reduced," says Klaus Schmidt. "CAMSO has become our standard across the entire fleet."',
    productId: 'p001',
    rating: 5,
    date: '2024-10-15',
    tags: [
      'Demolition',
      'Germany',
      'Skid Steer',
    ],
    isFeatured: true,
  ),

  Testimonial(
    id: 't002',
    type: 'Product Story',
    title: 'CTL 400 Tracks Proven in Queensland Extreme Heat',
    company: 'Pacific Earthworks Pty Ltd',
    location: 'Brisbane, Australia',
    contact: 'Mark Thompson, Site Supervisor',
    avatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&auto=format',
    coverImage:
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600&h=350&fit=crop&auto=format',
    excerpt:
        'Operating in Queensland extreme heat and rocky terrain, the CTL 400 tracks exceeded manufacturer estimates by 15% over 18 months.',
    content:
        'Queensland construction sites present some of the harshest operating conditions in the world. Extreme heat, abrasive volcanic rock, and demanding deadlines push equipment to its limits.\n\n'
        'Pacific Earthworks has been using CAMSO CTL 400 rubber tracks on their Caterpillar CTL fleet for 18 months. The results have been impressive. Track life exceeded manufacturer estimates by 15%, and the tracks performed without failure through Queensland\'s summer heat peaks.\n\n'
        'The self-cleaning lug design has proven essential in the clay soils common to pipeline construction work in the region. Our preventive maintenance intervals have also been extended, saving approximately AUD 14,000 per year in maintenance costs.',
    productId: 'p003',
    rating: 5,
    date: '2024-09-20',
    tags: [
      'Australia',
      'Track Loaders',
      'Extreme Heat',
    ],
    isFeatured: true,
  ),

  Testimonial(
    id: 't003',
    type: 'Tutorial',
    title: 'How to Properly Tension Your CTL Rubber Tracks',
    company: 'CAMSO Technical Team',
    location: 'Global',
    contact: 'CAMSO Field Application Engineer',
    avatar:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=80&h=80&fit=crop&auto=format',
    coverImage:
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=350&fit=crop&auto=format',
    excerpt:
        'Proper track tensioning is the single most impactful factor for rubber track service life. This guide walks through the complete process.',
    content:
        'Proper installation and tensioning is critical to getting maximum performance from your CAMSO rubber tracks. This guide covers the tensioning procedure for CTL series tracks.\n\n'
        'Step 1: Clean the undercarriage thoroughly before inspection.\n'
        'Step 2: Check sprocket and idler wheel condition for wear.\n'
        'Step 3: With the machine on level ground, measure sag at the midpoint between idler and sprocket.\n'
        'Step 4: The sag should measure 25–40mm under normal conditions, 30–45mm in muddy conditions.\n'
        'Step 5: Re-check after first 8 hours of operation as new tracks will seat slightly.\n'
        'Step 6: Inspect tension monthly thereafter under normal operations.',
    productId: 'p003',
    rating: 4,
    date: '2024-08-10',
    tags: [
      'Tutorial',
      'Installation',
      'Maintenance',
    ],
    isFeatured: false,
  ),

  Testimonial(
    id: 't004',
    type: 'Replacement Story',
    title: 'MH 701 Saved Our Fleet 3 Weeks of Downtime',
    company: 'Buildworks Solutions Inc.',
    location: 'Ontario, Canada',
    contact: 'Sarah Mitchell, Fleet Manager',
    avatar:
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=350&fit=crop&auto=format',
    coverImage:
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=350&fit=crop&auto=format',
    excerpt:
        'When a competitor tire failure halted production during a critical deadline, CAMSO MH 701 delivered emergency supply within 72 hours.',
    content:
        'When our previous tire supplier failed to deliver during our busiest project season, we turned to CAMSO as an emergency solution. The MH 701 tires were delivered within 72 hours and our distributor handled the installation at our site.\n\n'
        'The performance has been so impressive that we\'ve made CAMSO our preferred supplier for all telehandler tires across our 22-machine fleet. The load capacity and stability improvements are measurable — our operators report noticeably better confidence when working at maximum lift height.\n\n'
        '"We\'ve never looked back," says Sarah Mitchell. "The emergency response from CAMSO\'s distribution network was outstanding."',
    productId: 'p002',
    rating: 5,
    date: '2024-07-28',
    tags: [
      'Canada',
      'Telehandler',
      'Fleet Management',
    ],
    isFeatured: false,
  ),
];

final documents = [
  const Document(
    id: 'd001',
    title: 'SKS S1 Installation Manual',
    type: 'Installation Manual',
    category: 'manuals',
    fileSize: '4.2 MB',
    format: 'PDF',
    date: '2024-11-15',
    version: '2.3',
    description:
        'Complete installation guide for SKS S1 series skid steer tires. Includes torque specifications and safety procedures.',
    productId: 'p001',
    pages: 48,
    language: 'EN / FR / DE / IT',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.public,
  ),

  const Document(
    id: 'd002',
    title: 'CAMSO Product Catalog 2024–25',
    type: 'Brochure',
    category: 'brochures',
    fileSize: '18.7 MB',
    format: 'PDF',
    date: '2024-09-01',
    version: '1.0',
    description:
        'Full product range catalog featuring all Compact Construction Tires and Tracks for the 2024–25 season.',
    productId: null,
    pages: 112,
    language: 'EN / FR / DE / IT',
    isDownloaded: true,
    accessLevel: DocumentAccessLevel.public,
  ),

  const Document(
    id: 'd003',
    title: 'CTL 400 Maintenance Guide',
    type: 'Maintenance Guide',
    category: 'maintenance',
    fileSize: '6.1 MB',
    format: 'PDF',
    date: '2024-10-22',
    version: '3.1',
    description:
        'Comprehensive maintenance schedule and inspection procedures for CTL 400 series rubber tracks.',
    productId: 'p003',
    pages: 64,
    language: 'EN / FR / DE / IT',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.public,
  ),

  const Document(
    id: 'd004',
    title: 'MH 701 Technical Bulletin TB-2024-08',
    type: 'Technical Bulletin',
    category: 'technical',
    fileSize: '1.8 MB',
    format: 'PDF',
    date: '2024-08-15',
    version: '1.0',
    description:
        'Critical update regarding inflation pressure recommendations for MH 701 series in high-temperature environments.',
    productId: 'p002',
    pages: 12,
    language: 'EN / FR / DE / IT',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.public,
  ),

  const Document(
    id: 'd005',
    title: 'CAMSO 2-Year Warranty Policy',
    type: 'Warranty Document',
    category: 'warranty',
    fileSize: '0.9 MB',
    format: 'PDF',
    date: '2024-01-01',
    version: '5.2',
    description:
        'Complete warranty terms, conditions, and claim procedures for all CAMSO by CEAT products.',
    productId: null,
    pages: 24,
    language: 'EN / FR / DE / IT',
    isDownloaded: true,
    accessLevel: DocumentAccessLevel.public,
  ),

  const Document(
    id: 'd007',
    title: 'XTR 770 Product Data Sheet',
    type: 'Brochure',
    category: 'brochures',
    fileSize: '2.1 MB',
    format: 'PDF',
    date: '2024-11-18',
    version: '1.0',
    description:
        'Technical data sheet and product highlights for the new XTR 770 extreme terrain tire range.',
    productId: 'p006',
    pages: 8,
    language: 'EN / FR / DE / IT',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.public,
  ),

  // Dealer Restricted Documents
  const Document(
    id: 'd008',
    title: 'Dealer Commercial Sales & Margin Schedule',
    type: 'Brochure',
    category: 'brochures',
    fileSize: '3.4 MB',
    format: 'PDF',
    date: '2024-10-01',
    version: '1.2',
    description:
        'Confidential authorized dealer pricing tiers, rebate structures, and wholesale margin schedules for CAMSO products.',
    productId: null,
    pages: 18,
    language: 'EN / FR / DE',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.dealer,
  ),

  const Document(
    id: 'd009',
    title: 'Dealer Warranty Claim & RMA Processing Manual',
    type: 'Warranty Document',
    category: 'warranty',
    fileSize: '2.3 MB',
    format: 'PDF',
    date: '2024-09-15',
    version: '2.0',
    description:
        'Step-by-step procedures for authorized dealers to submit fast-track warranty claims, photographic inspections, and return authorizations.',
    productId: null,
    pages: 28,
    language: 'EN / FR / DE',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.dealer,
  ),

  // Distributor Restricted Documents
  const Document(
    id: 'd010',
    title: 'Regional Distribution Logistics & Supply Allocation',
    type: 'Technical Bulletin',
    category: 'technical',
    fileSize: '4.8 MB',
    format: 'PDF',
    date: '2024-10-12',
    version: '3.0',
    description:
        'Regional warehouse stocking plans, container order logistics, and seasonal buffer allocation matrix for regional distributors.',
    productId: null,
    pages: 36,
    language: 'EN',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.distributor,
  ),

  // Employee Restricted Documents
  const Document(
    id: 'd011',
    title: 'CEAT Employee Handbook & Field Operations Guide',
    type: 'Maintenance Guide',
    category: 'maintenance',
    fileSize: '5.5 MB',
    format: 'PDF',
    date: '2024-08-01',
    version: '4.1',
    description:
        'Internal corporate guidelines, safety procedures, application engineering protocols, and staff operational directory.',
    productId: null,
    pages: 84,
    language: 'EN',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.employee,
  ),

  const Document(
    id: 'd012',
    title: 'Internal Engineering Specifications & Compound Standards',
    type: 'Technical Bulletin',
    category: 'technical',
    fileSize: '7.2 MB',
    format: 'PDF',
    date: '2024-10-30',
    version: '2024-R3',
    description:
        'Confidential R&D data sheet on rubber compound hardness, tensile ratings, steel cord metallurgy, and internal testing metrics.',
    productId: null,
    pages: 52,
    language: 'EN',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.employee,
  ),

  // OEM Partner Restricted Documents
  const Document(
    id: 'd013',
    title: 'OEM Fitment & Engineering Integration Matrix',
    type: 'Technical Bulletin',
    category: 'technical',
    fileSize: '6.7 MB',
    format: 'PDF',
    date: '2024-11-01',
    version: '2025.1',
    description:
        'Technical engineering drawings, hub flange clearances, rolling circumference tolerances, and chassis integration specifications for OEM machinery.',
    productId: null,
    pages: 96,
    language: 'EN / DE',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.oem,
  ),

  const Document(
    id: 'd014',
    title: 'CAMSO 3D CAD & Technical Drawing Index',
    type: 'Installation Manual',
    category: 'manuals',
    fileSize: '12.4 MB',
    format: 'PDF',
    date: '2024-09-20',
    version: '1.4',
    description:
        'STEP/IGES file index and 3D boundary dimensions for original equipment manufacturers integrating CAMSO tracks and wheels.',
    productId: null,
    pages: 42,
    language: 'EN',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.oem,
  ),

  // Admin Only Documents
  const Document(
    id: 'd015',
    title: 'CAMSO Platform Governance & Content Audit Report',
    type: 'Brochure',
    category: 'brochures',
    fileSize: '1.5 MB',
    format: 'PDF',
    date: '2024-11-10',
    version: '1.0',
    description:
        'Quarterly content governance review, CMS audit log summary, and digital catalogue synchronization status.',
    productId: null,
    pages: 14,
    language: 'EN',
    isDownloaded: false,
    accessLevel: DocumentAccessLevel.admin,
  ),
];

const image1 =
    'https://images.unsplash.com/photo-1763516763181-4372f2987360?w=600&h=600&fit=crop&auto=format';

const image2 =
    'https://images.unsplash.com/photo-1742070122920-3480a94cfbbb?w=600&h=600&fit=crop&auto=format';

const image3 =
    'https://images.unsplash.com/photo-1580901369227-308f6f40bdeb?w=600&h=600&fit=crop&auto=format';

const image4 =
    'https://images.unsplash.com/photo-1541487880852-afcef8ba6d2c?w=600&h=600&fit=crop&auto=format';

const image5 =
    'https://images.unsplash.com/photo-1580901368919-7738efb0f87e?w=600&h=600&fit=crop&auto=format';

const image6 =
    'https://images.unsplash.com/photo-1763515187944-821eaca2426b?w=600&h=600&fit=crop&auto=format';

const image7 =
    'https://images.unsplash.com/photo-1760197384870-183647c3d57b?w=600&h=600&fit=crop&auto=format';

const categories=[
 {'id':'cat-1','name':'Skid Steer Tires','count':18,'image':'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=200&fit=crop&auto=format'},
 {'id':'cat-2','name':'Telehandler Tires','count':14,'image':'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=300&h=200&fit=crop&auto=format'},
 {'id':'cat-3','name':'Rubber Tracks','count':22,'image':'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=300&h=200&fit=crop&auto=format'},
 {'id':'cat-4','name':'Steel Tracks','count':16,'image':'https://images.unsplash.com/photo-1656797654768-f3b5883a0fbf?w=300&h=200&fit=crop&auto=format'},
 {'id':'cat-5','name':'Backhoe Tires','count':10,'image':'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=300&h=200&fit=crop&auto=format'},
 {'id':'cat-6','name':'Excavator Tracks','count':28,'image':'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=300&h=200&fit=crop&auto=format'},
];

final products=[
 Product(id:'p001',name:'SKS S1 Skid Steer Tire',pid:'SKS-S1-10-16.5',category:'skid-steer',categoryName:'Skid Steer Tires',size:'10-16.5',plyRating:'10PR',treadDepth:'22mm',loadIndex:'F (12-ply)',maxLoad:'2,630 kg',maxSpeed:'40 km/h',description:'Heavy-duty skid steer tire engineered for superior traction on mixed terrain. The aggressive tread pattern is optimized for muddy, rocky, and paved surfaces delivering outstanding durability in demanding construction environments.',features:['Deep tread design for maximum traction','Reinforced sidewalls resist cuts and impacts','Wide footprint for superior stability','Low heat buildup compound'],applications:['Skid Steer Loaders','Compact Track Loaders','Construction Sites','Urban Projects'],compatibleEquipment:['Bobcat S650','Caterpillar 262D3','Case SR270','John Deere 332G','Kubota SSV75'],specifications:{'Overall Diameter':'680 mm','Section Width':'267 mm','Rim Diameter':'16.5"','Tread Width':'225 mm','Static Radius':'308 mm','Weight':'28.5 kg','Rim Flange':'8.25 in'},image:image1,isNew:true,isFeatured:true,rating:4.7,reviewCount:84),
 Product(id:'p002',name:'MH 701 Telehandler Tire',pid:'MH701-460-70R24',category:'telehandler',categoryName:'Telehandler Tires',size:'460/70R24',plyRating:'16PR',treadDepth:'25mm',loadIndex:'B (159A8)',maxLoad:'3,250 kg',maxSpeed:'50 km/h',description:'Premium radial telehandler tire providing exceptional stability for telescopic handlers in lifting applications. Optimized for mixed on-road and off-road use with low rolling resistance and high load capacity.',features:['Radial steel belt construction','Self-cleaning tread blocks','High load capacity design','Fuel-efficient low RR'],applications:['Telehandlers','Rough Terrain Forklifts','Material Handlers','Agricultural Use'],compatibleEquipment:['JCB 540-170','Manitou MT 1840','Merlo P72.10','Liebherr T 60-9'],specifications:{'Overall Diameter':'1080 mm','Section Width':'468 mm','Rim Diameter':'24"','Tread Width':'380 mm','Static Radius':'521 mm','Weight':'89.0 kg','Rim Flange':'16 in'},image:image2,isNew:false,isFeatured:true,rating:4.5,reviewCount:62),
 Product(id:'p003',name:'CTL 400 Rubber Track',pid:'CTL400-400X86X52',category:'rubber-tracks',categoryName:'Rubber Tracks',size:'400x86x52',plyRating:'N/A',treadDepth:'30mm',loadIndex:'N/A',maxLoad:'4,500 kg',maxSpeed:'14 km/h',description:'High-performance rubber track for compact track loaders featuring steel cord reinforcement and an advanced rubber compound for extended service life.',features:['Triple steel cord reinforcement','Bolt-on drive lugs','Low ground pressure design','Excellent surface protection'],applications:['Compact Track Loaders','Pipeline Construction','Landscaping','Soft Ground Operations'],compatibleEquipment:['Bobcat T870','Caterpillar 287D3','Case TV620B','Kubota SVL97-2'],specifications:{'Width':'400 mm','Pitch':'86 mm','Links':'52','Track Length':'4,472 mm','Lugs per Track':'26','Weight':'148.0 kg','Sag':'25–40 mm'},image:image3,isNew:true,isFeatured:false,rating:4.8,reviewCount:113),
 Product(id:'p004',name:'MPT 653 Multi-Purpose Tire',pid:'MPT653-335-80R18',category:'backhoe',categoryName:'Backhoe Tires',size:'335/80R18',plyRating:'12PR',treadDepth:'20mm',loadIndex:'F (143A8)',maxLoad:'2,100 kg',maxSpeed:'65 km/h',description:'Versatile multi-purpose tire for backhoe loaders requiring both on-road efficiency and off-road grip.',features:['All-terrain pattern','Low road noise','Self-cleaning design','Excellent load distribution'],applications:['Backhoe Loaders','Road Construction','Urban Projects','Utility Work'],compatibleEquipment:['JCB 3CX','Caterpillar 420F2','Komatsu WB97R-8','Case 590SN'],specifications:{'Overall Diameter':'915 mm','Section Width':'344 mm','Rim Diameter':'18"','Tread Width':'280 mm','Static Radius':'440 mm','Weight':'54.0 kg','Rim Flange':'11 in'},image:image4,isNew:false,isFeatured:true,rating:4.3,reviewCount:47),
 Product(id:'p005',name:'DFG 303 Mini Excavator Track',pid:'DFG303-300X52.5X84',category:'excavator',categoryName:'Excavator Tracks',size:'300x52.5x84',plyRating:'N/A',treadDepth:'28mm',loadIndex:'N/A',maxLoad:'2,800 kg',maxSpeed:'5.5 km/h',description:'Precision-engineered rubber track for mini excavators. Asymmetric lug pattern ensures excellent traction in confined spaces while minimizing surface damage.',features:['Asymmetric lug pattern','Anti-vibration compound','Enhanced guide protection','Detrack-resistant design'],applications:['Mini Excavators','Narrow Trenching','Landscaping','Basement Work'],compatibleEquipment:['Kubota KX060-5','Yanmar SV60','Takeuchi TB260','Hitachi ZX60-6'],specifications:{'Width':'300 mm','Pitch':'52.5 mm','Links':'84','Track Length':'4,410 mm','Lugs per Track':'42','Weight':'96.0 kg','Sag':'20–35 mm'},image:image5,isNew:false,isFeatured:false,rating:4.6,reviewCount:78),
 Product(id:'p006',name:'XTR 770 Extreme Terrain Tire',pid:'XTR770-12-16.5',category:'skid-steer',categoryName:'Skid Steer Tires',size:'12-16.5',plyRating:'12PR',treadDepth:'27mm',loadIndex:'G (14-ply)',maxLoad:'3,150 kg',maxSpeed:'35 km/h',description:'Extreme duty skid steer tire built for the harshest quarry, demolition, and recycling applications.',features:['Ultra-reinforced carcass','Rim guard protection','Deep void ratio 35%','Impact-resistant compound'],applications:['Quarry Operations','Demolition','Recycling Facilities','Mining Surface'],compatibleEquipment:['Bobcat S850','Caterpillar 272D3','Mustang 3800V','Gehl V420'],specifications:{'Overall Diameter':'730 mm','Section Width':'308 mm','Rim Diameter':'16.5"','Tread Width':'260 mm','Static Radius':'342 mm','Weight':'38.0 kg','Rim Flange':'9.75 in'},image:image6,isNew:true,isFeatured:true,rating:4.9,reviewCount:31),
 Product(id:'p007',name:'STA 550 Steel Track Assembly',pid:'STA550-450X83.5X71',category:'steel-tracks',categoryName:'Steel Tracks',size:'450x83.5x71',plyRating:'N/A',treadDepth:'45mm',loadIndex:'N/A',maxLoad:'8,000 kg',maxSpeed:'8 km/h',description:'Heavy-duty steel track assembly for large compact track loaders operating in extreme abrasive conditions.',features:['Forged steel links','Replaceable rubber pads','Sealed joint system','Extended service intervals'],applications:['Large CTL Operations','Hard Rock Sites','Demolition Debris','Extreme Abrasion'],compatibleEquipment:['Caterpillar 299D3 XE','Bobcat T86','Doosan DL420','Volvo MCT145D'],specifications:{'Width':'450 mm','Pitch':'83.5 mm','Links':'71','Track Length':'5,929 mm','Pad Width':'430 mm','Weight':'380.0 kg','Shoe Type':'Triple grouser'},image:image7,isNew:false,isFeatured:false,rating:4.4,reviewCount:22),
];

final notifications=[
 AppNotification(id:'n001',type:'product_update',title:'New Product: XTR 770 Extreme Terrain Tire',body:'The all-new XTR 770 is now available for skid steer loaders. Engineered for quarry and demolition applications.',date:'2024-11-20T09:00:00Z',isRead:false,icon:'new',productId:'p006'),
 AppNotification(id:'n002',type:'technical_bulletin',title:'Technical Bulletin: MH 701 Pressure Update',body:'Important update regarding inflation pressure in high-temperature environments. Review TB-2024-08 immediately.',date:'2024-11-18T14:30:00Z',isRead:false,icon:'alert'),
 AppNotification(id:'n003',type:'announcement',title:'CAMSO at Bauma 2025',body:'Visit us at Hall B5, Stand 412 to see the full 2025 product lineup and live demonstrations.',date:'2024-11-15T10:00:00Z',isRead:true,icon:'info'),
 AppNotification(id:'n004',type:'product_update',title:'CTL 400 Series — Improved Steel Cord',body:'Updated steel cord reinforcement design provides 15% longer track life.',date:'2024-11-10T08:00:00Z',isRead:true,icon:'update',productId:'p003'),
 AppNotification(id:'n005',type:'promotion',title:'Winter Fleet Program — Act Now',body:'Prepare your fleet for winter. Special pricing available through authorized dealers until December 31.',date:'2024-11-05T12:00:00Z',isRead:true,icon:'promo'),
];

const popularSearches=['skid steer','mini excavator','10-16.5','rubber tracks','telehandler','backhoe'];
const recentSearches=['SKS S1','rubber track 400','telehandler tire','CTL 400'];
const List<Map<String, String>> businessTypes = [
  {
    'id': 'dealer',
    'name': 'Dealer',
    'description': 'Authorized CAMSO dealer selling direct to end users',
  },
  {
    'id': 'distributor',
    'name': 'Distributor',
    'description': 'Regional product distributor supplying dealer networks',
  },
  {
    'id': 'oem',
    'name': 'OEM Partner',
    'description': 'Original equipment manufacturer using CAMSO products',
  },
  {
    'id': 'employee',
    'name': 'CEAT Employee',
    'description': 'CEAT or CAMSO staff member',
  },
  {
    'id': 'admin',
    'name': 'Admin',
    'description': 'Platform administrator with full access',
  },
];
const languages=[{'code':'en','name':'English','native':'English','flag':'🇬🇧'},{'code':'fr','name':'French','native':'Français','flag':'🇫🇷'},{'code':'de','name':'German','native':'Deutsch','flag':'🇩🇪'},{'code':'it','name':'Italian','native':'Italiano','flag':'🇮🇹'}];

const List<FAQItem> mockFaqs = [
  // Product
  FAQItem(
    id: 'faq-01',
    category: 'Product',
    question: 'What is the expected operating lifespan of CAMSO skid steer tires?',
    answer: 'Under normal mixed construction conditions, CAMSO SKS tires deliver 1,000 to 1,500 operating hours. Lifespan varies depending on surface abrasiveness, operator habits, and daily maintenance routines.',
  ),
  FAQItem(
    id: 'faq-02',
    category: 'Product',
    question: 'What is the difference between solid and pneumatic skid steer tires?',
    answer: 'Pneumatic tires provide better operator comfort, shock absorption, and speed on rough terrain. Solid (aperture) tires are puncture-proof and designed for extreme demolition, scrap metal, and recycling facilities where downtime from flats is unacceptable.',
  ),
  FAQItem(
    id: 'faq-03',
    category: 'Product',
    question: 'Are CAMSO rubber tracks interchangeable across different compact track loader brands?',
    answer: 'Many CTL models share compatible track pitch and width specifications (such as 400x86x52 or 450x86x56). However, drive lug geometry and roller spacing must always match OEM specifications. Consult the Track Fitment Guide in Support & Resources.',
  ),

  // Technical
  FAQItem(
    id: 'faq-04',
    category: 'Technical',
    question: 'What is the recommended tire inflation pressure for telehandler tires?',
    answer: 'Inflation pressure depends on vehicle load index and axle configurations. For standard radial telehandler tires like the MH 701, typical operating pressures range between 4.0 and 5.5 bar (58 to 80 PSI). Check the technical data sheet for precise axle ratings.',
  ),
  FAQItem(
    id: 'faq-05',
    category: 'Technical',
    question: 'How do I measure proper track tension/sag on a mini excavator?',
    answer: 'Raise the track frame off the ground using the excavator arm and blade. Measure the clearance between the bottom of the center track roller and the top of the track rubber. Correct sag is generally between 20 mm and 35 mm.',
  ),
  FAQItem(
    id: 'faq-06',
    category: 'Technical',
    question: 'Can I retread or regroove CAMSO construction tires?',
    answer: 'Certain heavy-duty CAMSO bias and radial casing tires are designed with an extra undertread thickness suitable for regrooving by certified technicians. Always inspect casing integrity for steel cord damage before attempting.',
  ),

  // Warranty
  FAQItem(
    id: 'faq-07',
    category: 'Warranty',
    question: "What is CAMSO's standard warranty coverage on construction tires and tracks?",
    answer: 'CAMSO products are backed by a comprehensive limited warranty against manufacturing defects in materials and workmanship for up to 36 months from purchase date or until remaining usable tread reaches 10%, whichever occurs first.',
  ),
  FAQItem(
    id: 'faq-08',
    category: 'Warranty',
    question: 'How do I submit a warranty claim as a dealer or customer?',
    answer: 'Warranty claims can be submitted directly through your authorized dealer portal, or by contacting our Technical Support team with tire serial numbers, machine operating hours, and photographic documentation of the defect.',
  ),
  FAQItem(
    id: 'faq-09',
    category: 'Warranty',
    question: 'Are punctures and sidewall cuts covered under warranty?',
    answer: 'Accidental field damage such as punctures from rebar, rock sidewall cuts, and improper inflation are not covered under manufacturing defect warranties. Puncture-resistant solid tires are recommended for high-hazard work sites.',
  ),

  // Applications
  FAQItem(
    id: 'faq-10',
    category: 'Applications',
    question: 'Which tire tread is recommended for cold climates and snow removal?',
    answer: 'For winter operations, the CAMSO SKS 792S and directional block tread tires provide superior traction on packed snow and ice without sacrificing cleanout capability on slushy roads.',
  ),
  FAQItem(
    id: 'faq-11',
    category: 'Applications',
    question: 'What rubber track pattern is best for turf and finished landscaping?',
    answer: 'Non-marking multi-bar or zig-zag tread patterns distribute machine weight evenly, reducing ground pressure to as low as 4.2 PSI to prevent rutting and turf shearing on sensitive lawns and golf courses.',
  ),
  FAQItem(
    id: 'faq-12',
    category: 'Applications',
    question: 'Can I use skid steer tires on highway transport trailers?',
    answer: 'No. Construction skid steer tires are rated for industrial off-road speeds (typically maximum 25–40 km/h). They are not DOT-certified for high-speed highway transport trailers.',
  ),

  // Purchasing
  FAQItem(
    id: 'faq-13',
    category: 'Purchasing',
    question: 'How do I find my nearest authorized CAMSO distributor or dealer?',
    answer: 'Use the Dealer Support locator in the Support section of this app, or enter your postal code on our Dealer Finder to locate certified distributors with in-stock inventory.',
  ),
  FAQItem(
    id: 'faq-14',
    category: 'Purchasing',
    question: 'Can I order replacement tires and tracks directly through the app?',
    answer: 'Authorized dealers and distributors can place wholesale orders through their B2B portal. Registered end-users can request quotes and locate participating local dealers with inventory availability.',
  ),
  FAQItem(
    id: 'faq-15',
    category: 'Purchasing',
    question: 'What lead times should I expect for bulk OEM track shipments?',
    answer: 'Standard catalog sizes maintain active regional warehouse stock with 24–48 hour dispatch. Custom OEM compounds or high-volume container shipments typically require 3 to 6 weeks lead time.',
  ),
];


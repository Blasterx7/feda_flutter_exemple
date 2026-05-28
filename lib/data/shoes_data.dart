import '../models/shoe.dart';

const List<Shoe> shoesData = [
  Shoe(
    id: 'shoe_001',
    name: 'Air Runner Pro',
    brand: 'NovaSport',
    description:
        'Une chaussure de course légère et respirante, idéale pour les longues distances. Semelle amortissante pour un maximum de confort.',
    price: 45000,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    sizes: ['38', '39', '40', '41', '42', '43', '44', '45'],
    colors: ['Noir', 'Blanc', 'Rouge'],
    category: 'Running',
    isNew: true,
  ),
  Shoe(
    id: 'shoe_002',
    name: 'Urban Classic Low',
    brand: 'StreetWave',
    description:
        'Sneaker urbaine au style intemporel. Cuir synthétique de haute qualité, semelle en caoutchouc antidérapante. Parfaite pour un look casual.',
    price: 32000,
    oldPrice: 40000,
    imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600',
    sizes: ['37', '38', '39', '40', '41', '42', '43'],
    colors: ['Blanc', 'Beige', 'Noir'],
    category: 'Casual',
  ),
  Shoe(
    id: 'shoe_003',
    name: 'TrailBlazer X',
    brand: 'OutdoorPeak',
    description:
        'Chaussure de trail robuste avec semelle crantée. Tige imperméable, protection des orteils renforcée. Conçue pour les terrains difficiles.',
    price: 58000,
    imageUrl:
        'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600',
    sizes: ['39', '40', '41', '42', '43', '44', '45', '46'],
    colors: ['Kaki', 'Marron', 'Gris'],
    category: 'Trail',
    isNew: true,
  ),
  Shoe(
    id: 'shoe_004',
    name: 'Flex Court',
    brand: 'PlayZone',
    description:
        'Chaussure de basketball haute avec excellente traction. Support de cheville renforcé, coussin d\'air intégré pour absorber les impacts.',
    price: 52000,
    oldPrice: 65000,
    imageUrl:
        'https://images.unsplash.com/photo-1597045566677-8cf032ed6634?w=600',
    sizes: ['40', '41', '42', '43', '44', '45'],
    colors: ['Noir/Or', 'Blanc/Bleu', 'Rouge/Noir'],
    category: 'Sport',
  ),
  Shoe(
    id: 'shoe_005',
    name: 'Elegance Slip-On',
    brand: 'ModStyle',
    description:
        'Mocassin élégant sans lacets, doublure en cuir souple. Idéal pour les occasions formelles ou semi-formelles.',
    price: 28000,
    imageUrl:
        'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=600',
    sizes: ['38', '39', '40', '41', '42', '43', '44'],
    colors: ['Noir', 'Marron', 'Cognac'],
    category: 'Élégance',
  ),
  Shoe(
    id: 'shoe_006',
    name: 'Summer Breeze Sandal',
    brand: 'BeachLife',
    description:
        'Sandale légère à semelle épaisse, parfaite pour l\'été. Brides ajustables en nylon, semelle antidérapante.',
    price: 15000,
    oldPrice: 20000,
    imageUrl:
        'https://images.unsplash.com/photo-1571601811011-a028c52a0cd1?w=600',
    sizes: ['36', '37', '38', '39', '40', '41', '42'],
    colors: ['Blanc', 'Bleu Marine', 'Sable'],
    category: 'Sandales',
  ),
  Shoe(
    id: 'shoe_007',
    name: 'Power Boost',
    brand: 'NovaSport',
    description:
        'Chaussure de gym ultra-performante avec technologie Boost dans la semelle. Stabilité maximale pour les entraînements intensifs.',
    price: 61000,
    imageUrl:
        'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600',
    sizes: ['38', '39', '40', '41', '42', '43', '44', '45'],
    colors: ['Noir', 'Gris/Orange', 'Blanc/Vert'],
    category: 'Running',
    isNew: true,
  ),
  Shoe(
    id: 'shoe_008',
    name: 'Heritage Boot',
    brand: 'StreetWave',
    description:
        'Bottine au style vintage en cuir véritable. Semelle Goodyear welt, très durable. Un classique indémodable.',
    price: 75000,
    imageUrl:
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600',
    sizes: ['39', '40', '41', '42', '43', '44', '45'],
    colors: ['Marron foncé', 'Noir', 'Tan'],
    category: 'Boots',
  ),
];

const List<String> shoeCategories = [
  'Tous',
  'Running',
  'Casual',
  'Trail',
  'Sport',
  'Élégance',
  'Sandales',
  'Boots',
];

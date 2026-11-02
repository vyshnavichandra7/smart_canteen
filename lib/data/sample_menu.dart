import '../models/food_item.dart';

const sampleMenu = <FoodItem>[
  FoodItem(
    id: 'idli',
    name: 'Idli',
    description: 'Soft steamed idlis with chutney',
    category: 'Breakfast',
    price: 35,
    imageUrl:
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800',
    isPopular: true,
  ),
  FoodItem(
    id: 'dosa',
    name: 'Masala Dosa',
    description: 'Crisp dosa with a spiced potato filling',
    category: 'Breakfast',
    price: 55,
    imageUrl:
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800',
    isPopular: true,
  ),
  FoodItem(
    id: 'sandwich',
    name: 'Veg Sandwich',
    description: 'Toasted bread, fresh veggies and green chutney',
    category: 'Snacks',
    price: 50,
    imageUrl:
        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800',
    isPopular: true,
  ),
  FoodItem(
    id: 'samosa',
    name: 'Samosa',
    description: 'Golden pastry with a savory potato filling',
    category: 'Snacks',
    price: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
  ),
  FoodItem(
    id: 'puff',
    name: 'Veg Puff',
    description: 'Flaky puff pastry filled with spiced vegetables',
    category: 'Snacks',
    price: 25,
    imageUrl:
        'https://images.unsplash.com/photo-1625220194771-7ebdea0b70b9?w=800',
  ),
  FoodItem(
    id: 'fried-rice',
    name: 'Veg Fried Rice',
    description: 'Wok-tossed rice with garden vegetables',
    category: 'Meals',
    price: 90,
    imageUrl:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800',
    isPopular: true,
  ),
  FoodItem(
    id: 'meals',
    name: 'Veg Meals',
    description: 'A comforting plate with rice and seasonal sides',
    category: 'Meals',
    price: 110,
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800',
  ),
  FoodItem(
    id: 'chicken-biryani',
    name: 'Chicken Biryani',
    description: 'Fragrant basmati rice with spiced chicken',
    category: 'Meals',
    price: 140,
    imageUrl:
        'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=800',
    isPopular: true,
  ),
  FoodItem(
    id: 'maggi',
    name: 'Masala Maggi',
    description: 'Warm noodles tossed with a masala seasoning',
    category: 'Snacks',
    price: 45,
    imageUrl:
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800',
  ),
  FoodItem(
    id: 'tea',
    name: 'Tea',
    description: 'Freshly brewed classic chai',
    category: 'Beverages',
    price: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=800',
    isPopular: true,
  ),
  FoodItem(
    id: 'coffee',
    name: 'Coffee',
    description: 'A warm cup of filter-style coffee',
    category: 'Beverages',
    price: 25,
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
    isAvailable: false,
  ),
  FoodItem(
    id: 'lime-soda',
    name: 'Fresh Lime Soda',
    description: 'A refreshing lime drink, sweet or salted',
    category: 'Beverages',
    price: 35,
    imageUrl:
        'https://images.unsplash.com/photo-1513558161293-cdab7659dd92?w=800',
  ),
];

const foodCategories = ['All', 'Breakfast', 'Snacks', 'Meals', 'Beverages'];

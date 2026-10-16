import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FittedStoreApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class FittedStoreApp extends StatelessWidget {
  const FittedStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JYZRIZ Streetwear',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF18181B),
        primaryColor: Colors.black,
        useMaterial3: true,
      ),
      home: const MobileFrameWrapper(),
    );
  }
}

class StreetwearItem {
  final String name;
  final String brand;
  final double price;
  final String imageUrl;

  StreetwearItem({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
  });
}

class CartEntry {
  final StreetwearItem item;
  final String selectedSize;

  CartEntry({required this.item, required this.selectedSize});
}

enum PaymentMethod { cashOnDelivery, bankTransfer }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return Icons.payments_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
    }
  }
}

class OrderHistoryEntry {
  final String orderId;
  final List<CartEntry> items;
  final double totalPrice;
  final String orderDate;
  final String estimatedDelivery;
  final PaymentMethod paymentMethod;
  String status; // 'Preparing Item', 'Cancelled'

  OrderHistoryEntry({
    required this.orderId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.estimatedDelivery,
    required this.paymentMethod,
    this.status = 'Preparing Item',
  });
}

List<CartEntry> globalCart = [];
List<OrderHistoryEntry> globalOrderHistory = [];

enum AppView { shop, productDetail, cart, orderHistory, orderDetail }

class MobileFrameWrapper extends StatefulWidget {
  const MobileFrameWrapper({super.key});

  @override
  State<MobileFrameWrapper> createState() => _MobileFrameWrapperState();
}

class _MobileFrameWrapperState extends State<MobileFrameWrapper> {
  AppView currentView = AppView.shop;
  StreetwearItem? selectedItem;
  OrderHistoryEntry? selectedOrder;

  void openProductDetail(StreetwearItem item) {
    setState(() {
      selectedItem = item;
      currentView = AppView.productDetail;
    });
  }

  void openCart() {
    setState(() {
      currentView = AppView.cart;
    });
  }

  void openOrderHistory() {
    setState(() {
      currentView = AppView.orderHistory;
    });
  }

  void openOrderDetail(OrderHistoryEntry order) {
    setState(() {
      selectedOrder = order;
      currentView = AppView.orderDetail;
    });
  }

  void backToShop() {
    setState(() {
      currentView = AppView.shop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 375,
          height: 750,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFF27272A), width: 10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 25,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('9:41', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        width: 80,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.signal_cellular_alt, size: 14),
                          SizedBox(width: 4),
                          Icon(Icons.wifi, size: 14),
                          SizedBox(width: 4),
                          Icon(Icons.battery_full, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case AppView.cart:
        return CartInsideView(onBack: backToShop);
      case AppView.orderHistory:
        return OrderHistoryView(
          onBack: backToShop,
          onSelectOrder: openOrderDetail,
        );
      case AppView.orderDetail:
        return OrderDetailView(
          order: selectedOrder!,
          onBack: openOrderHistory,
        );
      case AppView.productDetail:
        return ProductDetailScreen(
          item: selectedItem!,
          onBack: backToShop,
        );
      case AppView.shop:
      default:
        return FittedShopInsideScreen(
          onOpenCart: openCart,
          onOpenHistory: openOrderHistory,
          onSelectItem: openProductDetail,
        );
    }
  }
}

class FittedShopInsideScreen extends StatefulWidget {
  final VoidCallback onOpenCart;
  final VoidCallback onOpenHistory;
  final Function(StreetwearItem) onSelectItem;

  const FittedShopInsideScreen({
    super.key,
    required this.onOpenCart,
    required this.onOpenHistory,
    required this.onSelectItem,
  });

  @override
  State<FittedShopInsideScreen> createState() => _FittedShopInsideScreenState();
}

class _FittedShopInsideScreenState extends State<FittedShopInsideScreen> {
  final List<StreetwearItem> products = [
    StreetwearItem(
      name: 'Supreme Box Logo Tee',
      brand: 'Supreme',
      price: 6500.0,
      imageUrl: 'https://www.resellzonecesena.com/cdn/shop/files/supreme-box-logo-t-shirt-black-fw23-resellzone.jpg?v=1735395292&width=1065',
    ),
    StreetwearItem(
      name: 'BAPE Shark Zip Hoodie',
      brand: 'BAPE',
      price: 2500.0,
      imageUrl: 'https://int.bape.com/cdn/shop/files/0ZXSWM009151QRDX-pdp-2.jpg?v=1772794940&width=1200',
    ),
    StreetwearItem(
      name: 'Supreme Camo Hoodie',
      brand: 'Supreme',
      price: 2800.0,
      imageUrl: 'https://www.resellzonecesena.com/cdn/shop/files/supreme-b-b-simon-zip-up-hooded-sweatshirt-camo-resellzone.jpg?v=1748279130&width=1065',
    ),
    StreetwearItem(
      name: 'BAPE Ape Head Camo Tee',
      brand: 'BAPE',
      price: 5899.0,
      imageUrl: 'https://int.bape.com/cdn/shop/files/0ZXTEM007101RBKM-pdp-1.jpg?v=1787913204&width=800',
    ),
    StreetwearItem(
      name: 'Supreme Hooded Sweatshirt',
      brand: 'Supreme',
      price: 2250.0,
      imageUrl: 'https://puresoles.ph/cdn/shop/files/Screenshot2026-04-28at11.30.27AM.png?v=1777906261&width=1946',
    ),
    StreetwearItem(
      name: 'BAPE Pullover Hoodie',
      brand: 'BAPE',
      price: 5599.0,
      imageUrl: 'https://images.stockx.com/images/BAPE-Logo-Relaxed-Fit-Pullover-Hoodie-FW22-Green.jpg?fit=fill&bg=FFFFFF&w=700&h=500&fm=webp&auto=compress&q=90&dpr=2&trim=color&updated_at=1667200300',
    ),
    StreetwearItem(
      name: 'CARHART WIP logo',
      brand: 'CARHART',
      price: 2099.0,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCapry-Wtl2qaLBOwCEk1PVqMJWcxisRHAqZufVtYhPF6VpwnrgGtnywrt&s=10',
    ),
    StreetwearItem(
      name: 'CHROME HEARTS longs sleeve',
      brand: 'CHROME HEARTS',
      price: 5000.0,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTVczePC_F2eSWYTVsNQ9jaASUkfwp59usjXg4fZhVpsQ75qyBOzQSjF8&s=10',
    ),
    StreetwearItem(
      name: 'CHROME HEARTS hoodie',
      brand: 'CHROME HEARTS',
      price: 8999.0,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkkdZAVMkNz8n0Q17BCbPBj9CCkL1rwjWujSoZVlYRP1N4rMRtlJNEuahK&s=10',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('JYZRIZ streetwear', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
            Text('Streetwear Collection', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black, size: 24),
            onPressed: widget.onOpenHistory,
            tooltip: 'Order History',
          ),
          GestureDetector(
            onTap: widget.onOpenCart,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 26),
                  ),
                  if (globalCart.isNotEmpty)
                    const CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '!',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return GestureDetector(
            onTap: () => widget.onSelectItem(item),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.brand,
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final StreetwearItem item;
  final VoidCallback onBack;

  const ProductDetailScreen({
    super.key,
    required this.item,
    required this.onBack,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String currentSelectedSize = 'M';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: Text(widget.item.brand, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.item.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.brand,
                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${widget.item.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Authentic high-quality streetwear piece from JYZRIZ collection. Made with premium fabric designed for comfort and durability.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Size:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      bool isSelected = currentSelectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => currentSelectedSize = size),
                        child: Container(
                          width: 50,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : const Color(0xFFE4E4E7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  globalCart.add(CartEntry(item: widget.item, selectedSize: currentSelectedSize));
                  widget.onBack();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to Cart!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartInsideView extends StatefulWidget {
  final VoidCallback onBack;
  const CartInsideView({super.key, required this.onBack});

  @override
  State<CartInsideView> createState() => _CartInsideViewState();
}

class _CartInsideViewState extends State<CartInsideView> {
  PaymentMethod selectedPaymentMethod = PaymentMethod.cashOnDelivery;

  @override
  Widget build(BuildContext context) {
    double totalCartValue = globalCart.fold(0, (sum, entry) => sum + entry.item.price);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text('Your Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: globalCart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Your cart is empty.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: globalCart.length,
                    itemBuilder: (context, index) {
                      final entry = globalCart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(entry.item.imageUrl, width: 45, height: 45, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('Size: ${entry.selectedSize}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  Text('₱${entry.item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  globalCart.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment method selector
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...PaymentMethod.values.map((method) {
                        final isSelected = selectedPaymentMethod == method;
                        return GestureDetector(
                          onTap: () => setState(() => selectedPaymentMethod = method),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method.icon,
                                  size: 20,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    method.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  size: 18,
                                  color: isSelected ? Colors.white : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('₱${totalCartValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Order Placed!'),
                                content: Text(
                                  'Thank you for shopping at JYZRIZ streetwear!\n\n'
                                  'Payment Method: ${selectedPaymentMethod.label}\n\n'
                                  'Your order will arrive in 3-5 business days.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      final newOrder = OrderHistoryEntry(
                                        orderId: 'JYZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                        items: List.from(globalCart),
                                        totalPrice: totalCartValue,
                                        orderDate: "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}",
                                        estimatedDelivery: "3-5 Business Days",
                                        paymentMethod: selectedPaymentMethod,
                                      );

                                      globalOrderHistory.add(newOrder);

                                      setState(() {
                                        globalCart.clear();
                                      });
                                      Navigator.pop(ctx);
                                      widget.onBack();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class OrderHistoryView extends StatefulWidget {
  final VoidCallback onBack;
  final Function(OrderHistoryEntry) onSelectOrder;

  const OrderHistoryView({
    super.key,
    required this.onBack,
    required this.onSelectOrder,
  });

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text('Order History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: globalOrderHistory.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No order history yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: globalOrderHistory.length,
              itemBuilder: (context, index) {
                final order = globalOrderHistory[index];
                bool isCancelled = order.status == 'Cancelled';

                return GestureDetector(
                  onTap: () => widget.onSelectOrder(order),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCancelled ? Colors.red.shade50 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isCancelled ? Colors.red : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(order.orderDate, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(order.paymentMethod.icon, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              order.paymentMethod.label,
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...order.items.map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(entry.item.imageUrl, width: 35, height: 35, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${entry.item.name} (${entry.selectedSize})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text('₱${entry.item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.green)),
                                ],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('₱${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                          ],
                        ),
                        if (!isCancelled) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Cancel Order?'),
                                    content: Text('Are you sure you want to cancel order ${order.orderId}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            order.status = 'Cancelled';
                                          });
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Cancel Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OrderDetailView extends StatelessWidget {
  final OrderHistoryEntry order;
  final VoidCallback onBack;

  const OrderDetailView({
    super.key,
    required this.order,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    bool isCancelled = order.status == 'Cancelled';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        title: Text(order.orderId, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCancelled ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isCancelled ? Icons.cancel_outlined : Icons.local_shipping,
                    color: isCancelled ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Status', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        isCancelled ? 'Cancelled' : order.estimatedDelivery,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCancelled ? Colors.red : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Payment method info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(order.paymentMethod.icon, color: Colors.black87, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        order.paymentMethod.label,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...order.items.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(entry.item.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('Size: ${entry.selectedSize}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('₱${entry.item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('₱${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
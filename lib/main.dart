import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const GrabberApp());
}

class GrabberApp extends StatelessWidget {
  const GrabberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grabber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF22C55E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case SplashScreen.route:
            page = const SplashScreen();
            break;
          case HomeScreen.route:
            page = const HomeScreen();
            break;
          case CartScreen.route:
            page = const CartScreen();
            break;
          case CheckoutScreen.route:
            page = const CheckoutScreen();
            break;
          case PaymentScreen.route:
            final arg = settings.arguments as PaymentArgs?;
            page = PaymentScreen(selectedMethod: arg?.selectedMethod ?? PaymentMethod.card);
            break;
          case ConfirmingScreen.route:
            page = const ConfirmingScreen();
            break;
          case TrackingScreen.route:
            page = const TrackingScreen();
            break;
          default:
            page = const SplashScreen();
        }
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) {
            final offset = Tween(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: anim.drive(offset), child: child);
          },
        );
      },
      initialRoute: SplashScreen.route,
    );
  }
}

// =============================
// Splash Screen
// =============================
class SplashScreen extends StatefulWidget {
  static const route = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, HomeScreen.route);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
          child: const Text(
            'Grabber',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF22C55E),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================
// Data Models / Dummy Data
// =============================
class Product {
  final String id;
  final String name;
  final String unit;
  final double price;
  final String imageUrl;
  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.imageUrl,
  });
}

final demoProducts = <Product>[
  Product(
    id: 'banana',
    name: 'Banana',
    unit: '1 dozen',
    price: 2.99,
    imageUrl:
        'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=1239&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop',
  ),
  Product(
    id: 'pepper',
    name: 'Pepper',
    unit: '500 g',
    price: 1.99,
    imageUrl:
        'https://images.unsplash.com/photo-1525607551316-4a8e16d1f9ba?q=80&w=710&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop',
  ),
  Product(
    id: 'orange',
    name: 'Orange',
    unit: '1 kg',
    price: 3.49,
    imageUrl:
        'https://images.unsplash.com/photo-1547514701-42782101795e?q=80&w=800&auto=format&fit=crop',
  ),
  Product(
    id: 'milk',
    name: 'Milk',
    unit: '1 L',
    price: 1.20,
    imageUrl:
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=800&auto=format&fit=crop',
  ),
];

// Simple in-memory cart
class CartModel extends ChangeNotifier {
  final Map<Product, int> items = {};
  void add(Product p) {
    items.update(p, (v) => v + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void remove(Product p) {
    if (!items.containsKey(p)) return;
    if (items[p]! > 1) {
      items[p] = items[p]! - 1;
    } else {
      items.remove(p);
    }
    notifyListeners();
  }

  double get subtotal => items.entries
      .map((e) => e.key.price * e.value)
      .fold(0.0, (a, b) => a + b);
}

final cart = CartModel();

// =============================
// Home Screen
// =============================
class HomeScreen extends StatefulWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Offer carousel banners
            SizedBox(
              height: 150,
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _current = i),
                children: const [
                  _OfferBanner(
                    title: 'Up to 30% off',
                    subtitle: 'On fruits & veggies',
                    imageUrl:
                        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1200&auto=format&fit=crop',
                  ),
                  _OfferBanner(
                    title: 'Get Same-day Delivery',
                    subtitle: 'On orders above \$20',
                    imageUrl:
                        'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200&auto=format&fit=crop',
                  ),
                  _OfferBanner(
                    title: 'Fresh Picks Daily',
                    subtitle: 'Local farms to you',
                    imageUrl:
                        'https://images.unsplash.com/photo-1524594227085-3e4ce4b6d915?q=80&w=1200&auto=format&fit=crop',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => _Dot(active: i == _current)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Fruits',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: demoProducts.length,
                itemBuilder: (context, i) {
                  final p = demoProducts[i];
                  return _ProductCard(product: p, onAdd: () {
                    cart.add(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${p.name} added to cart')),
                    );
                    setState(() {});
                  });
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
        onDestinationSelected: (i) {
          if (i == 2) {
            Navigator.pushNamed(context, CartScreen.route);
          }
        },
      ),
    );
  }
}

class _OfferBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  const _OfferBanner(
      {required this.title, required this.subtitle, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Shop now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF22C55E) : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    lowerBound: 0.98,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return ScaleTransition(
      scale: _pulse,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(p.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(p.unit, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text('\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () {
                  _pulse.reverse().then((value) => _pulse.forward());
                  widget.onAdd();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================
// Cart Screen
// =============================
class CartScreen extends StatefulWidget {
  static const route = '/cart';
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...cart.items.entries.map((e) => _CartItemRow(
                product: e.key,
                qty: e.value,
                onMinus: () => setState(() => cart.remove(e.key)),
                onPlus: () => setState(() => cart.add(e.key)),
              )),
          const SizedBox(height: 12),
          if (cart.items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Your cart is empty'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed: cart.items.isEmpty
              ? null
              : () => Navigator.pushNamed(context, CheckoutScreen.route),
          child: Text('Go to checkout  (\$${cart.subtotal.toStringAsFixed(2)})'),
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final Product product;
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _CartItemRow({
    required this.product,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Text(product.name),
        subtitle: Text(product.unit),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
            Text('$qty'),
            IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
          ],
        ),
      ),
    );
  }
}

// =============================
// Checkout Screen
// =============================
enum DeliveryOption { standard, schedule }

class CheckoutScreen extends StatefulWidget {
  static const route = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DeliveryOption _delivery = DeliveryOption.standard;
  TimeOfDay? _scheduledTime;
  bool _needInvoice = false;
  PaymentMethod _method = PaymentMethod.card;

  double get deliveryFee => _delivery == DeliveryOption.standard ? 1.00 : 0.50;

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.subtotal;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Delivery', style: TextStyle(fontWeight: FontWeight.w700)),
          RadioListTile<DeliveryOption>(
            value: DeliveryOption.standard,
            groupValue: _delivery,
            onChanged: (v) => setState(() => _delivery = v!),
            title: const Text('Standard (45–60 mins)'),
          ),
          RadioListTile<DeliveryOption>(
            value: DeliveryOption.schedule,
            groupValue: _delivery,
            onChanged: (v) async {
              setState(() => _delivery = v!);
              final picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 18, minute: 0),
              );
              setState(() => _scheduledTime = picked);
            },
            title: Text(
                'Schedule${_scheduledTime != null ? ' (${_scheduledTime!.format(context)})' : ''}'),
          ),
          const SizedBox(height: 8),
          const Text('Order Summary',
              style: TextStyle(fontWeight: FontWeight.w700)),
          _kv('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _kv('Delivery', '\$${deliveryFee.toStringAsFixed(2)}'),
          const Divider(),
          _kv('Total', '\$${total.toStringAsFixed(2)}', bold: true),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _needInvoice,
            onChanged: (v) => setState(() => _needInvoice = v),
            title: const Text('Request an invoice'),
          ),
          const SizedBox(height: 8),
          const Text('Payment method',
              style: TextStyle(fontWeight: FontWeight.w700)),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.applepay,
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            title: const Text('Apple Pay'),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.card,
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v!),
            title: const Text('Pay with card'),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed: () {
            Navigator.pushNamed(context, PaymentScreen.route,
                arguments: PaymentArgs(selectedMethod: _method));
          },
          child: const Text('Place Order'),
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(k),
      trailing: Text(v,
          style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    );
  }
}

// =============================
// Payment Screen + Confirm
// =============================
enum PaymentMethod { applepay, card }

class PaymentArgs {
  final PaymentMethod selectedMethod;
  PaymentArgs({required this.selectedMethod});
}

class PaymentScreen extends StatefulWidget {
  static const route = '/payment';
  final PaymentMethod selectedMethod;
  const PaymentScreen({super.key, required this.selectedMethod});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _method;
  final _cardCtrl = TextEditingController(text: '5465 2817 9250 2783');
  final _expCtrl = TextEditingController(text: '02/19');
  final _cvcCtrl = TextEditingController(text: '•••');

  @override
  void initState() {
    super.initState();
    _method = widget.selectedMethod;
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.applepay,
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v),
            title: const Text('Apple Pay'),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.card,
            groupValue: _method,
            onChanged: (v) => setState(() => _method = v),
            title: const Text('Pay with card'),
          ),
          if (_method == PaymentMethod.card) ...[
            const SizedBox(height: 6),
            TextField(
              controller: _cardCtrl,
              decoration: const InputDecoration(
                labelText: 'Card number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Expiry',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvcCtrl,
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, ConfirmingScreen.route);
            },
            child: const Text('Confirm and Pay (\$4.98)'),
          ),
        ],
      ),
    );
  }
}

class ConfirmingScreen extends StatefulWidget {
  static const route = '/confirming';
  const ConfirmingScreen({super.key});
  @override
  State<ConfirmingScreen> createState() => _ConfirmingScreenState();
}

class _ConfirmingScreenState extends State<ConfirmingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, TrackingScreen.route);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _ctrl,
              child: const Icon(Icons.delivery_dining, size: 64, color: Color(0xFF22C55E)),
            ),
            const SizedBox(height: 16),
            const Text('Confirming your order'),
          ],
        ),
      ),
    );
  }
}

// =============================
// Tracking Screen (Map with animated path + moving courier)
// =============================
class TrackingScreen extends StatefulWidget {
  static const route = '/tracking';
  const TrackingScreen({super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _moveCtrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();

  int _stage = 0; // 0 picking, 1 packing, 2 out for delivery

  @override
  void initState() {
    super.initState();
    // Cycle stages every few seconds to mimic progress
    Timer.periodic(const Duration(seconds: 3), (t) {
      if (!mounted) return;
      setState(() => _stage = (_stage + 1) % 3);
    });
  }

  @override
  void dispose() {
    _moveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stages = ['Picking up your order…', 'Packing your orders…', 'Out for delivery'];
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static map image background
                Image.network(
                  'https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
                // Dotted path painter
                CustomPaint(
                  painter: _DottedPathPainter(),
                  child: const SizedBox.expand(),
                ),
                // Moving courier icon along path
                AnimatedBuilder(
                  animation: _moveCtrl,
                  builder: (context, child) {
                    final t = _moveCtrl.value; // 0..1
                    final pt = _pathPoint(t);
                    return Positioned(
                      left: pt.dx - 14,
                      top: pt.dy - 14,
                      child: Transform.rotate(
                        angle: pt.direction,
                        child: child,
                      ),
                    );
                  },
                  child: const Icon(Icons.two_wheeler, size: 28, color: Color(0xFF22C55E)),
                ),
                // Destination pin
                const Positioned(
                  right: 28,
                  top: 60,
                  child: Icon(Icons.location_pin, size: 36, color: Colors.redAccent),
                ),
              ],
            ),
          ),
          _TrackingBottomSheet(stage: _stage, stageLabel: stages[_stage]),
        ],
      ),
    );
  }

  // Define a polyline-like path inside the map area and compute a point along it
  _PathPoint _pathPoint(double t) {
    // Path points (relative positions inside the map stack)
    const pts = [
      Offset(40, 260),
      Offset(120, 200),
      Offset(220, 240),
      Offset(280, 160),
      Offset(340, 120),
      Offset(380, 80),
      Offset(420, 70),
    ];
    // Interpolate along segments
    final totalSegments = pts.length - 1;
    final segT = t * totalSegments;
    final i = segT.floor().clamp(0, totalSegments - 1);
    final localT = segT - i;
    final a = pts[i];
    final b = pts[i + 1];
    final pos = Offset(
      a.dx + (b.dx - a.dx) * localT,
      a.dy + (b.dy - a.dy) * localT,
    );
    final dir = math.atan2(b.dy - a.dy, b.dx - a.dx);
    return _PathPoint(pos, dir);
  }
}

class _PathPoint {
  final Offset position;
  final double direction;
  const _PathPoint(this.position, this.direction);
  double get dx => position.dx;
  double get dy => position.dy;
}

class _DottedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(40, 260)
      ..lineTo(120, 200)
      ..lineTo(220, 240)
      ..lineTo(280, 160)
      ..lineTo(340, 120)
      ..lineTo(380, 80)
      ..lineTo(size.width - 40, 70);

    // Draw dotted effect by path metrics
    final dashWidth = 8, dashSpace = 6;
    for (final metric in path.computeMetrics()) {
      double dist = 0.0;
      while (dist < metric.length) {
        final next = math.min(dist + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackingBottomSheet extends StatelessWidget {
  final int stage; // 0,1,2
  final String stageLabel;
  const _TrackingBottomSheet({required this.stage, required this.stageLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stage == 2
                    ? Icons.delivery_dining
                    : stage == 1
                        ? Icons.shopping_basket
                        : Icons.storefront,
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(width: 8),
              Text(stageLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              const Text('Arriving at 11:45'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1511367461989-f85a21fda167?q=80&w=200&auto=format&fit=crop'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('James Williams', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('Rating 4.8 ★'),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat'),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text('Tip your shopper'),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final tip in [2, 5, 10, 15])
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('\$${tip.toStringAsFixed(0)}.00'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  } 
}

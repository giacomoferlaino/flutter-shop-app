import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import './providers/cart.dart';
import './providers/products.dart';
import './providers/orders.dart';
import './providers/shop_filters.dart';
import './providers/auth.dart';
import './pages/orders_page.dart';
import './pages/cart_page.dart';
import './pages/products_overview_page.dart';
import './pages/product_detailt_page.dart';
import './pages/user_products_page.dart';
import './pages/edit_product_page.dart';
import './pages/auth_page.dart';
import './services/product_service.dart';
import './services/snack_bar_service.dart';
import './services/order_service.dart';
import './services/auth_service.dart';
import 'services/http_service.dart';

const String baseUrl = 'http://10.0.2.2:8080';

void serviceLocatorSetup() {
  GetIt serviceLocator = GetIt.instance;
  serviceLocator.registerSingleton<HttpService>(HttpService());
  serviceLocator.registerSingleton<ProductService>(ProductService(baseUrl));
  serviceLocator.registerSingleton<OrderService>(OrderService(baseUrl));
  serviceLocator.registerSingleton<AuthService>(AuthService(baseUrl));
  serviceLocator.registerSingleton<SnackBarService>(
    SnackBarService(
      duration: Duration(seconds: 2),
    ),
  );
}

void main() {
  serviceLocatorSetup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (context) => Orders(),
        ),
        ChangeNotifierProvider(
          create: (context) => ShopFilters(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            errorColor: Color.fromRGBO(191, 1, 1, 0.7),
            fontFamily: 'Lato',
          ),
          home: auth.isAuth ? ProductsOverviewPage() : AuthPage(),
          routes: {
            AuthPage.routeName: (context) => AuthPage(),
            ProductsOverviewPage.routeName: (context) => ProductsOverviewPage(),
            ProductDetailPage.routeName: (context) => ProductDetailPage(),
            CartPage.routeName: (context) => CartPage(),
            OrdersPage.routeName: (context) => OrdersPage(),
            UserProductsPage.routeName: (context) => UserProductsPage(),
            EditProductPage.routeName: (context) => EditProductPage(),
          },
        ),
      ),
    );
  }
}

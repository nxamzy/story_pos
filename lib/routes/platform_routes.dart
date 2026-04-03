class RouteInfo {
  final String name;
  final String route;

  const RouteInfo({required this.name, required this.route});
}

class PlatformRoutes {
  static const firstPage = RouteInfo(name: 'first', route: '/');
  static const secondsPage = RouteInfo(name: 'seconds', route: '/seconds');
  static const thirtPage = RouteInfo(name: 'thirt', route: '/thirt');
  static const homePage = RouteInfo(name: 'home', route: '/home');
  static const cashDrawerPage = RouteInfo(name: 'cash', route: '/cash');
  static const notificationsPage = RouteInfo(
    name: 'notifications',
    route: '/notifications',
  );
  static const showAllProfile = RouteInfo(name: 'show', route: '/show');
  static const settingsPage = RouteInfo(name: 'settings', route: '/settings');
  static const profilePage = RouteInfo(name: 'profile', route: '/profile');
  static const signUpPage = RouteInfo(name: 'signup', route: '/signup');
  static const loginPage = RouteInfo(name: 'login', route: '/login');
  static const forgotPasswordPage = RouteInfo(name: 'forgot', route: '/forgot');
  static const verification = RouteInfo(
    name: 'verification',
    route: '/verification',
  );
  static const salePage = RouteInfo(name: 'sale', route: '/sale');
  static const chanegePassword = RouteInfo(name: 'change', route: '/change');
  static const selectProfilePage = RouteInfo(name: 'select', route: '/select');
  static const customersPage = RouteInfo(
    name: 'customers',
    route: '/customers',
  );
  static const customerdetailsPage = RouteInfo(
    name: 'customer_details',
    route: '/customer_details',
  );
  static const addNewCustomerPage = RouteInfo(
    name: 'new_customer',
    route: '/new_customer',
  );
  static const employeeHRMPage = RouteInfo(
    name: 'employee',
    route: '/employee',
  );
  static const addEmployee = RouteInfo(
    name: 'addemployee',
    route: '/addemployee',
  );
  static const inventoryPage = RouteInfo(
    name: 'inventory',
    route: '/inventory',
  );
  static const repostsPage = RouteInfo(name: 'reposts', route: '/reposts');
  static const addNewProduct = RouteInfo(
    name: 'newProduct',
    route: '/newProduct',
  );
  static const productDetails = RouteInfo(
    name: 'productDetails',
    route: '/productDetails',
  );
  static const supplierPage = RouteInfo(name: 'supplier', route: '/supplier');
  static const supplierDetailsPage = RouteInfo(
    name: 'supplierDetails',
    route: '/supplierDetails',
  );
  static const addNewSupplierPage = RouteInfo(
    name: 'addNewSupplier',
    route: '/addNewSupplier',
  );
  static const basketPage = RouteInfo(name: 'basket', route: '/basket');
  static const checkoutPage = RouteInfo(name: 'checkout', route: '/checkout');
  static const scanProductPage = RouteInfo(name: 'scan', route: '/scan');
  static const receiptPage = RouteInfo(name: 'receipt', route: '/receipt');
  static const test = RouteInfo(name: 'test', route: '/test');
}

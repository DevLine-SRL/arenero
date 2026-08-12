abstract final class RoutePaths {
  static const home = '/';
  static const login = '/login';
  static const dashboard = '/panel';
  static const registerSale = '/ventas/registrar';
  static const salesHistory = '/ventas/historial';
  static const saleDetail = '/ventas/historial/:id';
  static const clients = '/clientes';
  static const products = '/productos';
  static const sellersManagement = '/vendedores';
  static const forbidden = '/forbidden';
}

abstract final class RouteNames {
  static const login = 'login';
  static const dashboard = 'dashboard';
  static const registerSale = 'registerSale';
  static const salesHistory = 'salesHistory';
  static const saleDetail = 'saleDetail';
  static const clients = 'clients';
  static const products = 'products';
  static const sellersManagement = 'sellersManagement';
  static const forbidden = 'forbidden';
}

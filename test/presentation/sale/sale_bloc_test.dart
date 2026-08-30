import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/repositories/product_repository.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_event.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_state.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockSaleRepository extends Mock implements SaleRepository {}

class FakeSaleModel extends Fake implements SaleModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSaleModel());
  });

  late MockProductRepository productRepository;
  late MockSaleRepository saleRepository;

  final inStockProduct = ProductModel(
    id: 'p1',
    name: 'Coca-Cola',
    barcode: '123',
    buyPrice: 5000,
    sellPrice: 8000,
    stock: 2,
  );

  final outOfStockProduct = ProductModel(
    id: 'p2',
    name: 'Suv',
    barcode: '456',
    buyPrice: 1000,
    sellPrice: 2000,
    stock: 0,
  );

  setUp(() {
    productRepository = MockProductRepository();
    saleRepository = MockSaleRepository();
  });

  SaleBloc buildBloc() => SaleBloc(
    productRepository: productRepository,
    saleRepository: saleRepository,
  );

  group('AddProductToCartEvent', () {
    blocTest<SaleBloc, SaleState>(
      'mahsulotni birinchi marta savatga qo\'shadi',
      build: buildBloc,
      act: (bloc) => bloc.add(AddProductToCartEvent(inStockProduct)),
      expect: () => [
        isA<SaleState>()
            .having((s) => s.cartItems.length, 'cartItems.length', 1)
            .having((s) => s.totalQuantity, 'totalQuantity', 1)
            .having((s) => s.subTotal, 'subTotal', 8000),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'bir xil mahsulot qayta qo\'shilsa miqdorini oshiradi',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(AddProductToCartEvent(inStockProduct))
        ..add(AddProductToCartEvent(inStockProduct)),
      skip: 1,
      expect: () => [
        isA<SaleState>()
            .having((s) => s.cartItems.length, 'cartItems.length', 1)
            .having((s) => s.totalQuantity, 'totalQuantity', 2)
            .having((s) => s.subTotal, 'subTotal', 16000),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'omborda qolgan miqdordan ko\'p qo\'shishga yo\'l qo\'ymaydi',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(AddProductToCartEvent(inStockProduct)) // 1/2
        ..add(AddProductToCartEvent(inStockProduct)) // 2/2 - chegara
        ..add(AddProductToCartEvent(inStockProduct)), // rad etiladi
      skip: 2,
      expect: () => [
        isA<SaleState>()
            .having((s) => s.totalQuantity, 'totalQuantity', 2)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'omborda tugagan mahsulotni savatga qo\'shmaydi',
      build: buildBloc,
      act: (bloc) => bloc.add(AddProductToCartEvent(outOfStockProduct)),
      expect: () => [
        isA<SaleState>()
            .having((s) => s.cartItems, 'cartItems', isEmpty)
            .having((s) => s.error, 'error', contains('tugagan')),
      ],
    );
  });

  group('UpdateQuantityEvent', () {
    blocTest<SaleBloc, SaleState>(
      'miqdorni 0 ga tushirish savatdan olib tashlaydi',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(AddProductToCartEvent(inStockProduct))
        ..add(UpdateQuantityEvent(inStockProduct.id, 0)),
      skip: 1,
      expect: () => [
        isA<SaleState>().having((s) => s.cartItems, 'cartItems', isEmpty),
      ],
    );
  });

  group('CompleteSaleEvent', () {
    blocTest<SaleBloc, SaleState>(
      'to\'langan summa yetarli bo\'lmasa xato beradi va Firestore\'ga yozmaydi',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(AddProductToCartEvent(inStockProduct))
        ..add(const CompleteSaleEvent(amountPaid: 1000)),
      skip: 1,
      expect: () => [
        isA<SaleState>().having(
          (s) => s.error,
          'error',
          contains('yetarli emas'),
        ),
      ],
      verify: (_) {
        verifyNever(() => saleRepository.createSale(any()));
      },
    );

    blocTest<SaleBloc, SaleState>(
      'bo\'sh savatni yakunlashga urinsa xato beradi',
      build: buildBloc,
      act: (bloc) => bloc.add(const CompleteSaleEvent(amountPaid: 1000)),
      expect: () => [
        isA<SaleState>().having((s) => s.error, 'error', "Savat bo'sh"),
      ],
    );
  });
}

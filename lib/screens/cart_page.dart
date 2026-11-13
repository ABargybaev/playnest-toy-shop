import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_bloc.dart';
import '../theme.dart';
import '../widgets/empty_panel.dart';
import '../widgets/toy_art.dart';

class CartPage extends StatelessWidget {
  final VoidCallback onBrowse;
  const CartPage({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) => BlocBuilder<CartBloc, CartState>(
    builder: (context, state) {
      if (state.lines.isEmpty) {
        return EmptyPanel(
          emoji: '🛒', title: 'Корзина ждёт чудес!',
          description: 'Добавьте пару игрушек, чтобы собрать свою маленькую коллекцию.',
          button: 'В каталог', onPressed: onBrowse,
        );
      }
      final lines = state.lines.values.toList();
      return SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 23, 18, 16),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Моя корзина 🛍️', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: PlayColors.ink)),
              SizedBox(height: 5),
              Text('Все понравившиеся игрушки в одном месте',
                style: TextStyle(color: PlayColors.muted, fontSize: 12)),
            ])),
            TextButton(
              onPressed: () => context.read<CartBloc>().add(const CartCleared()),
              child: const Text('Очистить', style: TextStyle(color: PlayColors.purple)),
            ),
          ]),
        ),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: lines.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _CartItem(line: lines[index]),
        )),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: PlayColors.ink, borderRadius: BorderRadius.circular(26),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Всего игрушек: ${state.count}', style: const TextStyle(color: Color(0xFFCBC5E7), fontSize: 13)),
              const Text('Итого', style: TextStyle(color: Color(0xFFCBC5E7), fontSize: 13)),
            ]),
            const SizedBox(height: 7),
            Align(alignment: Alignment.centerRight,
              child: Text('\$${state.total.toStringAsFixed(2)}', style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28))),
            const SizedBox(height: 8),
            const Text('Демо: оплата и отправка заказа не подключены.',
              style: TextStyle(fontSize: 11, color: Color(0xFFCBC5E7))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                backgroundColor: PlayColors.amber, foregroundColor: PlayColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.arrow_back_rounded), label: const Text('Продолжить покупки'),
            )),
          ]),
        ),
      ]));
    },
  );
}

class _CartItem extends StatelessWidget {
  final CartLine line;
  const _CartItem({required this.line});
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CartBloc>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFF2EFF8))),
      child: Row(children: [
        SizedBox(width: 91, height: 106, child: ToyArt(toy: line.toy)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(line.toy.name, maxLines: 2,
              overflow: TextOverflow.ellipsis, style: const TextStyle(
                color: PlayColors.ink, fontSize: 13, fontWeight: FontWeight.w800))),
            IconButton(
              onPressed: () => bloc.add(CartToyRemoved(line.toy.id)),
              icon: const Icon(Icons.close_rounded, size: 18, color: PlayColors.muted),
              tooltip: 'Удалить', visualDensity: VisualDensity.compact,
            ),
          ]),
          Text(line.toy.formattedPrice, style: const TextStyle(color: PlayColors.purple,
            fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 11),
          Row(children: [
            _QuantityButton(icon: Icons.remove_rounded,
              onTap: () => bloc.add(CartQuantityChanged(line.toy.id, -1))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.w900))),
            _QuantityButton(icon: Icons.add_rounded,
              onTap: () => bloc.add(CartQuantityChanged(line.toy.id, 1))),
          ]),
        ])),
      ]),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: PlayColors.paleViolet,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(9),
      child: SizedBox(width: 29, height: 29,
        child: Icon(icon, size: 17, color: PlayColors.purple))),
  );
}

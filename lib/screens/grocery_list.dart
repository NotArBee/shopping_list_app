import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/add_item_screen.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(context,
        MaterialPageRoute(builder: (context) => const AddItemScreen()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(GroceryItem groceryItem) {
    final groceryItemIndex = _groceryItems.indexOf(groceryItem);
    setState(() {
      _groceryItems.remove(groceryItem);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ColorScheme.of(context).secondaryContainer,
      content: Text(
        'Grocery Item is deleted',
        style: TextStyle(color: ColorScheme.of(context).onSecondaryContainer),
      ),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
          label: 'undo',
          textColor: ColorScheme.of(context).onSecondaryContainer,
          onPressed: () {
            setState(() {
              _groceryItems.insert(groceryItemIndex, groceryItem);
            });
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorScheme.of(context).primaryContainer,
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: _groceryItems.isEmpty
          ? Center(
              child: Text(
                'Nothing shopping added',
                style: TextTheme.of(context)
                    .titleLarge!
                    .copyWith(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (context, index) => Dismissible(
                    key: ValueKey(_groceryItems[index].id),
                    background: Container(
                      color: Colors.redAccent,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    onDismissed: (direction) {
                      _deleteItem(_groceryItems[index]);
                    },
                    child: ListTile(
                      title: Text(
                        _groceryItems[index].name,
                        style: TextTheme.of(context)
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                      leading: Container(
                        width: 24,
                        height: 24,
                        color: _groceryItems[index].category.color,
                      ),
                      trailing: Text(
                        _groceryItems[index].quantity.toString(),
                        style: TextTheme.of(context)
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  )),
    );
  }
}

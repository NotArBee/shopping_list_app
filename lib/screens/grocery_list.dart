import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/add_item_screen.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-81837-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
      });
    }

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

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

  void _deleteItem(GroceryItem groceryItem) async {
    final groceryItemIndex = _groceryItems.indexOf(groceryItem);
    final url = Uri.https(
        'flutter-prep-81837-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${groceryItem.id}.json');

    setState(() {
      _groceryItems.remove(groceryItem);
    });

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(groceryItemIndex, groceryItem);
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: ColorScheme.of(context).secondaryContainer,
        content: Text(
          'Error when deleting item. Please try again later',
          style: TextStyle(color: ColorScheme.of(context).onSecondaryContainer),
        ),
        duration: const Duration(seconds: 5),
      ));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: ColorScheme.of(context).secondaryContainer,
        content: Text(
          'Item is deleted',
          style: TextStyle(color: ColorScheme.of(context).onSecondaryContainer),
        ),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Nothing shopping added',
        style: TextTheme.of(context).titleLarge!.copyWith(color: Colors.white),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
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
              ));
    }

    if (_error != null) {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style:
                TextTheme.of(context).bodyLarge!.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorScheme.of(context).primaryContainer,
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}

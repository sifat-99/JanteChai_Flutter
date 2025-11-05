import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {

const List<String> categories = [
  "Politics",
  "Business & Finance",
  "World News",
  "Technology",
  "Health & Medicine",
  "Science & Environment",
  "Entertainment & Culture",
  "Sports",
  "Crime & Justice",
  "Education",
  "Lifestyle & Health",
  "Opinion & Analysis",
  "Odd & Interesting",
  "Travel & Adventure",
];


    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Categories Screen',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(categories[index]),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Category Tapped'),
                            content: Text('You tapped on ${categories[index]}.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

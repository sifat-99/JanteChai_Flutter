import 'package:flutter/material.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:jante_chai/services/news_api_service.dart';

class PublishNewsScreen extends StatefulWidget {
  const PublishNewsScreen({super.key});

  @override
  State<PublishNewsScreen> createState() => _PublishNewsScreenState();
}

class _PublishNewsScreenState extends State<PublishNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pictureUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pictureUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _publishNews() async {
    if (_formKey.currentState!.validate()) {
      try {
        await NewsApiService.publishNews(
          title: _titleController.text,
          description: _descriptionController.text,
          pictureUrl: _pictureUrlController.text,
          category: _categoryController.text,
          reporterEmail: authService.currentUser.value!.email,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News published successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to publish news: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pictureUrlController,
                decoration: const InputDecoration(labelText: 'Picture URL'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _publishNews,
                child: const Text('Publish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

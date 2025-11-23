import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _githubController;
  late TextEditingController _avatarUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = authService.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _githubController = TextEditingController(text: user?.github ?? '');
    _avatarUrlController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final success = await authService.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      github: _githubController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop(); // Go back to profile screen
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarPreview(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(
                  labelText: 'GitHub Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                onChanged: (value) {
                  setState(() {}); // Rebuild to update preview
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final url = _avatarUrlController.text.trim();
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
            child: url.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
            onBackgroundImageError: url.isNotEmpty
                ? (_, __) {
                    // Handle error silently, maybe show default icon
                  }
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 18,
              child: const Icon(Icons.edit, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

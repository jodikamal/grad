import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  File? _image;
  String _name = 'Jodi';
  String _email = 'jode@example.com';
  String _phone = '0791234567';
  String _address = 'Nablus, Palestine';

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 151, 90, 162),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _image != null
                          ? FileImage(_image!)
                          : const AssetImage(
                                'assets/images/profile_placeholder.png',
                              )
                              as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _buildField('Name', _name, (value) => _name = value),
              _buildField('Email', _email, (value) => _email = value),
              _buildField(
                'Phone Number',
                _phone,
                (value) => _phone = value,
                type: TextInputType.phone,
              ),
              _buildField('Address', _address, (value) => _address = value),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 194, 179, 197),
                ),
                child: const Text('     Save Changes         '),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String initialValue,
    Function(String) onSaved, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }
}

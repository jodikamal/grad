import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ipadress.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  int? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchProfile();
  }

  Future<void> _loadUserIdAndFetchProfile() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('userId');

    if (storedUserId == null) {
      _showErrorAndRedirect('User ID not found. Please log in again.');
      return;
    }

    setState(() => userId = storedUserId);
    await _fetchUserProfile(storedUserId);
  }

  Future<void> _fetchUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/profile/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() => userData = jsonDecode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorAndRedirect('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorAndRedirect(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f3fc),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade100,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(color: Colors.deepPurple),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (isLoading || userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final imageUrl =
        userData!['profile_image_url']?.toString().isNotEmpty == true
            ? userData!['profile_image_url']
            : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            userData!['name'] ?? 'Name not available',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            userData!['email'] ?? 'Email not available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.deepPurple.shade300,
            ),
          ),
          const SizedBox(height: 24),

          // Card container
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildProfileRow(
                    Icons.location_on,
                    'Address',
                    userData!['address'],
                  ),
                  const Divider(),
                  _buildProfileRow(Icons.phone, 'Phone', userData!['phone']),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _navigateToEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            ),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade300,
                ),
              ),
              Text(
                value ?? 'Not available',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: userData!),
      ),
    );

    if (updatedData != null) {
      setState(() => userData = updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }
}

//////////////////////////////////////////////////////

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _imageUrlController;
  bool _isLoading = false;
  int? _userId;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _addressController = TextEditingController(
      text: widget.userData['address'],
    );
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _imageUrlController = TextEditingController(
      text: widget.userData['profile_image_url'],
    );
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('http://$ip:3000/profile/$_userId');
      final request =
          http.MultipartRequest('PUT', uri)
            ..fields['name'] = _nameController.text
            ..fields['email'] = _emailController.text
            ..fields['address'] = _addressController.text
            ..fields['phone'] = _phoneController.text;

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          pickedFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageUrlController.text = updatedData['profile_image_url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image updated successfully')),
        );
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'profile_image_url': _imageUrlController.text,
      };

      final response = await http.put(
        Uri.parse('http://$ip:3000/profile/$_userId'), // تأكد من تعريف متغير ip
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, updatedData);
      } else {
        throw Exception('Failed to update: ${response.statusCode}');
      }
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProfile,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : NetworkImage(
                                      _imageUrlController.text.isNotEmpty
                                          ? _imageUrlController.text
                                          : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                                    )
                                    as ImageProvider,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Name'),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email'),
                    const SizedBox(height: 16),
                    _buildTextField(_addressController, 'Address'),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Phone'),
                    const SizedBox(height: 16),
                    _buildTextField(_imageUrlController, 'Profile Image URL'),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 116, 101, 142),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save Changes'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _selectedNationality = '';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _nationalities = [
    'Française',
    'Belge',
    'Suisse',
    'Canadienne',
    'Marocaine',
    'Algérienne',
    'Tunisienne',
    'Sénégalaise',
    'Ivoirienne',
    'Camerounaise',
    'Américaine',
    'Britannique',
    'Allemande',
    'Espagnole',
    'Italienne',
    'Portugaise',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson != null) {
      final profile = UserProfile.fromJsonString(profileJson);
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _heightController.text = profile.height > 0 ? profile.height.toString() : '';
      _weightController.text = profile.weight > 0 ? profile.weight.toString() : '';
      _ageController.text = profile.age > 0 ? profile.age.toString() : '';
      _selectedNationality = profile.nationality;
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    final profile = UserProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      height: double.tryParse(_heightController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      age: int.tryParse(_ageController.text) ?? 0,
      nationality: _selectedNationality,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', profile.toJsonString());

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Profil enregistré avec succès'),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A2F),
              Color(0xFF0D1F17),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2ECC71),
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Mon Profil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Formulaire
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF2ECC71),
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF2ECC71),
                                    size: 50,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Informations personnelles
                              _buildSectionTitle('Informations personnelles'),
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _firstNameController,
                                      label: 'Prénom',
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Requis';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _lastNameController,
                                      label: 'Nom',
                                      icon: Icons.badge_outlined,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Requis';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                controller: _ageController,
                                label: 'Âge',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                                suffix: 'ans',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requis';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 1 || age > 120) {
                                    return 'Âge invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              _buildDropdown(),
                              const SizedBox(height: 32),

                              // Mensurations
                              _buildSectionTitle('Mensurations'),
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _heightController,
                                      label: 'Taille',
                                      icon: Icons.height,
                                      keyboardType: TextInputType.number,
                                      suffix: 'cm',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Requis';
                                        }
                                        final height = double.tryParse(value);
                                        if (height == null || height < 50 || height > 250) {
                                          return 'Invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _weightController,
                                      label: 'Poids',
                                      icon: Icons.fitness_center,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      suffix: 'kg',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Requis';
                                        }
                                        final weight = double.tryParse(value);
                                        if (weight == null || weight < 20 || weight > 300) {
                                          return 'Invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Bouton sauvegarder
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2ECC71),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.save_outlined, size: 22),
                                            SizedBox(width: 8),
                                            Text(
                                              'Enregistrer',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF2ECC71),
          size: 22,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2ECC71),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedNationality.isEmpty ? null : _selectedNationality,
        hint: Text(
          'Sélectionnez votre nationalité',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        dropdownColor: const Color(0xFF1A3A2F),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.flag_outlined,
            color: Color(0xFF2ECC71),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez sélectionner une nationalité';
          }
          return null;
        },
        items: _nationalities.map((nationality) {
          return DropdownMenuItem<String>(
            value: nationality,
            child: Text(nationality),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedNationality = value ?? '';
          });
        },
      ),
    );
  }
}


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../config/theme_config.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _stockController;
  
  late String _selectedUnit;
  String? _photoUrl;
  File? _imageFile;
  bool _showPresets = false;

  final List<Map<String, String>> _brandPresets = [
    {
      'brand': 'Bashundhara',
      'label': 'Bashundhara 12kg Red',
      'url': 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&auto=format&fit=crop&q=60'
    },
    {
      'brand': 'Beximco',
      'label': 'Beximco Smart 12kg Composite',
      'url': 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&auto=format&fit=crop&q=60'
    },
    {
      'brand': 'Omera',
      'label': 'Omera LPG 12kg Blue',
      'url': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=60'
    },
    {
      'brand': 'Jamuna',
      'label': 'Jamuna Gas 12kg Yellow',
      'url': 'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=800&auto=format&fit=crop&q=60'
    },
    {
      'brand': 'Universal',
      'label': 'Universal Safety Regulator',
      'url': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=60'
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description ?? '');
    _priceController = TextEditingController(text: widget.product.price.toString());
    _discountController = TextEditingController(
      text: widget.product.discountPrice?.toString() ?? ''
    );
    _stockController = TextEditingController(text: widget.product.stockQuantity.toString());
    _selectedUnit = widget.product.unit;
    _photoUrl = widget.product.imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        final base64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _imageFile = file;
          _photoUrl = base64;
          _showPresets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final updates = {
      'id': widget.product.id,
      'category_id': widget.product.categoryId,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': _priceController.text.trim(),
      'discount_price': _discountController.text.trim(),
      'unit': _selectedUnit,
      'stock': _stockController.text.trim(),
      if (_photoUrl != null && _photoUrl!.isNotEmpty) 'photoUrl': _photoUrl,
    };

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.updateProduct(
      widget.product.id!,
      updates,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully'), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to update product'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product Photo & Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConfig.spaceLG),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo Management Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Product Photo / Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showPresets = !_showPresets;
                                  });
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                child: Text(
                                  _showPresets ? 'Hide presets' : '✨ Brand Presets',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFFF6600), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Image Preview
                          if (_photoUrl != null && _photoUrl!.isNotEmpty) ...[
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                image: _imageFile != null
                                    ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.contain)
                                    : DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.contain),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _photoUrl = null;
                                          _imageFile = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Brand presets picker
                          if (_showPresets) ...[
                            const Text('Select an official brand graphic:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 90,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _brandPresets.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final preset = _brandPresets[index];
                                  final isSelected = _photoUrl == preset['url'];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _photoUrl = preset['url'];
                                        _imageFile = null;
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFFF6600) : const Color(0xFFCBD5E1),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Image.network(
                                              preset['url']!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.propane_tank, color: Color(0xFFFF6600)),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            preset['brand']!,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Camera & Gallery action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFFFF6600)),
                                  label: const Text('Change Photo (Camera)', style: TextStyle(fontSize: 11, color: Color(0xFFFF6600))),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFF6600)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF475569)),
                                  label: const Text('Gallery', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(labelText: 'Discount Price', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'kg', child: Text('kg')),
                              DropdownMenuItem(value: 'liter', child: Text('liter')),
                              DropdownMenuItem(value: 'piece', child: Text('piece')),
                            ],
                            onChanged: (val) => setState(() => _selectedUnit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFF6600),
                      ),
                      onPressed: _submit,
                      child: const Text('Save Changes & Photo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

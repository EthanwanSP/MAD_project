import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/address.dart';
import '../app_theme.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _postalController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedAddressId;

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    Address address;
    final selected = _selectedAddressId;
    if (selected != null) {
      final snap = await _addressRef(selected).get();
      final data = snap.data();
      if (data == null) return;
      address = Address(
        line1: (data['line1'] as String?) ?? '',
        line2: data['line2'] as String?,
        postalCode: (data['postalCode'] as String?) ?? '',
      );
    } else {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      address = Address(
        line1: _line1Controller.text.trim(),
        line2: _line2Controller.text.trim().isEmpty
            ? null
            : _line2Controller.text.trim(),
        postalCode: _postalController.text.trim(),
      );
      await _saveAddress(address);
    }

    setState(() => _isSubmitting = true);
    try {
      await context.read<CartProvider>().checkout(address);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order placed'),
          content: const Text('Your order has been placed successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == '/shop' || route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to place order: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fromCart = args?['fromCart'] == true;
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kBlush,
        elevation: 0,
        title: Text('Delivery Address', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kInk),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text('Saved addresses', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _AddressList(
                selectedId: _selectedAddressId,
                onSelected: (id) {
                  setState(() {
                    _selectedAddressId = id;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Use a new address', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _Field(
                controller: _line1Controller,
                label: 'Address line 1',
                validator:
                    _selectedAddressId == null ? _requiredValidator : null,
              ),
              _Field(
                controller: _line2Controller,
                label: 'Address line 2 (optional)',
              ),
              _Field(
                controller: _postalController,
                label: 'Postal code',
                validator:
                    _selectedAddressId == null ? _requiredValidator : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSubmitting
                    ? null
                    : fromCart
                        ? _submit
                        : _saveOnly,
                style: FilledButton.styleFrom(
                  backgroundColor: kInk,
                  foregroundColor: kPaper,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(fromCart ? 'Confirm order' : 'Save address'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>> _addressesCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Please login to continue.');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');
  }

  DocumentReference<Map<String, dynamic>> _addressRef(String id) {
    return _addressesCollection().doc(id);
  }

  Future<void> _saveAddress(Address address) async {
    final data = address.toMap();
    final ref = _addressesCollection().doc();
    await ref.set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'defaultAddress': data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _setDefaultFromSelection(String id) async {
    final snap = await _addressRef(id).get();
    final data = snap.data();
    if (data == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'defaultAddress': {
        'line1': data['line1'],
        'line2': data['line2'],
        'postalCode': data['postalCode'],
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _saveOnly() async {
    Address address;
    final selected = _selectedAddressId;
    if (selected != null) {
      await _setDefaultFromSelection(selected);
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    address = Address(
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim().isEmpty
          ? null
          : _line2Controller.text.trim(),
      postalCode: _postalController.text.trim(),
    );
    await _saveAddress(address);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _AddressList extends StatelessWidget {
  const _AddressList({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text('Please login to view addresses.');
    }
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text(
            'No saved addresses yet',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final line1 = (data['line1'] as String?) ?? '';
            final line2 = (data['line2'] as String?) ?? '';
            final postal = (data['postalCode'] as String?) ?? '';
            final label = [
              line1,
              if (line2.isNotEmpty) line2,
              postal,
            ].where((e) => e.isNotEmpty).join(', ');
            return Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: doc.id,
                    groupValue: selectedId,
                    onChanged: onSelected,
                    title: Text(label),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('addresses')
                        .doc(doc.id)
                        .delete();
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

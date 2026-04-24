import 'package:flutter/material.dart';
import '../../Models/SellerModels/SellerPickupAddressModels.dart';

import '../../Repository/SellerRepository/SellerPickupAddressRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import 'AddPickupAddressScreen.dart';

class PickupAddressListScreen extends StatefulWidget {
  const PickupAddressListScreen({super.key});

  @override
  State<PickupAddressListScreen> createState() =>
      _PickupAddressListScreenState();
}

class _PickupAddressListScreenState extends State<PickupAddressListScreen> {
  final SellerPickupAddressRepository _repository = SellerPickupAddressRepository();

  List<PickupAddress> _addresses = [];
  bool _isLoading = true;
  bool _includeInactive = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final addresses = await _repository.getPickupAddresses(
        includeInactive: _includeInactive,
      );

      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to load addresses: $e');
      }
    }
  }

  Future<void> _refreshAddresses() async {
    await _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pickup / Warehouse Address',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      )
          : _addresses.isEmpty
          ? _buildEmptyState()
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshAddresses,
                color: Colors.black,
                child: ListView.builder(
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) =>
                      _buildAddressCard(_addresses[index], index),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Default address is used for all new shipment dispatches',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton(
          onPressed: () => _navigateToAddAddress(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Add new address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No pickup addresses found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pickup address to get started',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToAddAddress(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Add Address',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(PickupAddress address, int index) {
    final isDefault = address.isDefault;
    final isActive = address.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? const Color(0xFFC0DD97)
              : (isActive ? const Color(0xFFEEEEEE) : Colors.grey.shade200),
          width: isDefault ? 1.5 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'INACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          address.addressLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isActive ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildIconBtn(
                  Icons.edit_outlined,
                  onTap: () => _navigateToEditAddress(address),
                ),
                const SizedBox(width: 4),
                _buildIconBtn(
                  Icons.delete_outline,
                  onTap: () => _confirmDelete(address),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (address.company.isNotEmpty) ...[
              Text(
                address.company,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? Colors.grey.shade700 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              address.street,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            if (address.apartment.isNotEmpty) ...[
              Text(
                address.apartment,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
            Text(
              '${address.city}, ${address.state} ${address.zipCode}, ${address.country}',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            if (address.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                address.phoneNumber,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (isDefault && isActive) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xFF3B6D11),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Default pickup',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3B6D11),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isActive && !isDefault) ...[
              GestureDetector(
                onTap: () => _setAsDefault(address),
                child: Text(
                  'Set as default',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ] else if (!isActive) ...[
              GestureDetector(
                onTap: () => _activateAddress(address),
                child: Text(
                  'Activate address',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade600),
      ),
    );
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPickupAddressScreen(),
      ),
    );

    if (result != null && mounted) {
      await _refreshAddresses();
    }
  }

  Future<void> _navigateToEditAddress(PickupAddress address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPickupAddressScreen(addressToEdit: address),
      ),
    );

    if (result != null && mounted) {
      await _refreshAddresses();
    }
  }

  Future<void> _setAsDefault(PickupAddress address) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );

    try {
      await _repository.setDefaultPickupAddress(address.id);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        CustomSnackbar.showSuccess(context, 'Default address updated successfully');
        await _refreshAddresses();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        CustomSnackbar.showError(context, 'Failed to set default address: $e');
      }
    }
  }

  Future<void> _activateAddress(PickupAddress address) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Activate Address'),
        content: Text('Do you want to activate "${address.addressLabel}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Activate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );

    try {
      final request = UpdatePickupAddressRequest(isActive: true);
      await _repository.updatePickupAddress(address.id, request);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        CustomSnackbar.showSuccess(context, 'Address activated successfully');
        await _refreshAddresses();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        CustomSnackbar.showError(context, 'Failed to activate address: $e');
      }
    }
  }

  Future<void> _confirmDelete(PickupAddress address) async {
    // Check if it's the only active address
    final activeAddresses = _addresses.where((a) => a.isActive).length;
    final isOnlyActive = activeAddresses == 1 && address.isActive;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Delete this address?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              isOnlyActive
                  ? 'You cannot delete the only active address. Please add another address first.'
                  : 'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isOnlyActive ? Colors.red.shade600 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            if (!isOnlyActive)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close bottom sheet

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  );

                  try {
                    await _repository.deletePickupAddress(address.id);

                    if (mounted) {
                      Navigator.pop(context); // Close loading dialog
                      CustomSnackbar.showSuccess(context, 'Address deleted successfully');
                      await _refreshAddresses();
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Close loading dialog
                      CustomSnackbar.showError(context, 'Failed to delete address: $e');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
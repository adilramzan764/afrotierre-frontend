// lib/Repository/SellerRepository/SellerProductsRepo.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerProductModels.dart';
import '../../Services/AppSession.dart';
import '../../constants.dart';

class SellerProductsRepo {
  final http.Client client;

  SellerProductsRepo({http.Client? client}) : client = client ?? http.Client();

  String _buildUrl(String endpoint) {
    return '${ApiConstants.baseUrlSeller}$endpoint';
  }

  String? get _authToken => AppSession.instance.authToken;

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Create a new product
  Future<ProductResponse> createProduct({
    required CreateProductRequest request,
    List<File>? images,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(ApiConstants.createProduct));

      // Print request data for debugging
      print('📦 Creating product:');
      print('   Name: ${request.name}');
      print('   Price: ${request.price}');
      print('   Discounted Price: ${request.discountedPrice}');
      print('   Stock: ${request.stock}');
      print('   Category: ${request.category}');
      print('   Colors: ${request.colors}');
      print('   Attributes: ${request.attributes}');
      print('   Images: ${images?.length ?? 0}');
      print('   Is Draft: ${request.draft}');

      if (images != null && images.isNotEmpty) {
        // Multipart request for file upload
        var multipartRequest = http.MultipartRequest('POST', uri);
        multipartRequest.headers['Authorization'] = 'Bearer $_authToken';

        // Add text fields - send discountedPrice as string but ensure it's correct
        multipartRequest.fields['name'] = request.name;
        multipartRequest.fields['description'] = request.description;
        multipartRequest.fields['price'] = request.price.toString();

        // IMPORTANT: Only send discountedPrice if it has a value and is less than price
        if (request.discountedPrice != null && request.discountedPrice! > 0) {
          // Ensure discountedPrice is less than price
          if (request.discountedPrice! < request.price) {
            multipartRequest.fields['discountedPrice'] = request.discountedPrice.toString();
            print('   Sending discountedPrice: ${request.discountedPrice}');
          } else {
            print('   Warning: discountedPrice (${request.discountedPrice}) >= price (${request.price}), skipping');
          }
        }

        multipartRequest.fields['stock'] = request.stock.toString();
        multipartRequest.fields['category'] = request.category;
        multipartRequest.fields['colors'] = jsonEncode(request.colors);
        multipartRequest.fields['attributes'] = jsonEncode(request.attributes);
        multipartRequest.fields['sizes'] = jsonEncode(request.sizes);
        multipartRequest.fields['materials'] = jsonEncode(request.materials);
        multipartRequest.fields['draft'] = request.draft.toString();
        print('   Sending draft value: ${request.draft.toString()}'); // Debug print


        if (request.status != null) {
          multipartRequest.fields['status'] = request.status!;
        }
        if (request.image != null) {
          multipartRequest.fields['image'] = request.image!;
        }

        // Add images
        for (var i = 0; i < images.length && i < 3; i++) {
          final file = images[i];
          final mimeType = _getMimeType(file.path);
          final multipartFile = await http.MultipartFile.fromPath(
            'images',
            file.path,
            contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
          );
          multipartRequest.files.add(multipartFile);
        }

        print('📤 Sending multipart request with fields:');
        multipartRequest.fields.forEach((key, value) {
          print('   $key: $value');
        });

        final streamedResponse = await multipartRequest.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Create product response status: ${response.statusCode}');
        print('Create product response body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return ProductResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);

          // Extract error message properly
          String errorMessage = errorData['message'] ?? 'Failed to create product';

          // Check for errors array
          if (errorData['errors'] != null && errorData['errors'] is List) {
            final errors = errorData['errors'] as List;
            if (errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map && firstError['msg'] != null) {
                errorMessage = firstError['msg'];
              }
            }
          }

          print('📦 API Response: success=false, message=$errorMessage');

          return ProductResponse(
            success: false,
            message: errorMessage,
            error: errorData['error'],
          );
        }
      } else {
        // Regular JSON request
        final body = request.toJson();

        // Ensure discountedPrice is only included if valid
        if (body['discountedPrice'] != null) {
          final discPrice = body['discountedPrice'] as num?;
          final origPrice = body['price'] as num?;
          if (discPrice != null && origPrice != null && discPrice >= origPrice) {
            // Remove discountedPrice if it's invalid
            body.remove('discountedPrice');
            print('   Removed invalid discountedPrice (${discPrice} >= ${origPrice})');
          }
        }

        final response = await client.post(
          uri,
          headers: _getHeaders(),
          body: jsonEncode(body),
        );

        print('Create product response status: ${response.statusCode}');
        print('Create product response body: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return ProductResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);

          String errorMessage = errorData['message'] ?? 'Failed to create product';

          if (errorData['errors'] != null && errorData['errors'] is List) {
            final errors = errorData['errors'] as List;
            if (errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map && firstError['msg'] != null) {
                errorMessage = firstError['msg'];
              }
            }
          }

          print('📦 API Response: success=false, message=$errorMessage');

          return ProductResponse(
            success: false,
            message: errorMessage,
            error: errorData['error'],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }
  // Get seller products with filters
  Future<ProductResponse> getSellerProducts({
    String? status,
    String? category,
    int page = 1,
    int limit = 10,
    String? search,
    bool? draft,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (draft != null) queryParams['draft'] = draft.toString();

      final uri = Uri.parse(_buildUrl(ApiConstants.getSellerProducts))
          .replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: _getHeaders(),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get products',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting seller products: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get single product
  Future<ProductResponse> getProduct(String productId) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl('${ApiConstants.getProduct}/$productId')),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get product',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Update product
  Future<ProductResponse> updateProduct({
    required String productId,
    required UpdateProductRequest request,
    List<File>? newImages,
    List<String>? imagesToDelete, // Add this parameter
  }) async {
    try {
      final uri = Uri.parse(_buildUrl('${ApiConstants.updateProduct}/$productId'));

      print('📦 Updating product:');
      print('   Product ID: $productId');
      print('   Name: ${request.name}');
      print('   Price: ${request.price}');
      print('   Discounted Price: ${request.discountedPrice}');
      print('   Stock: ${request.stock}');
      print('   Category: ${request.category}');
      print('   Draft: ${request.draft}');
      print('   New Images: ${newImages?.length ?? 0}');
      print('   Images to delete: ${imagesToDelete?.length ?? 0}');

      if ((newImages != null && newImages.isNotEmpty) ||
          (request.image != null) ||
          (imagesToDelete != null && imagesToDelete.isNotEmpty)) {
        // Multipart request for file upload
        var multipartRequest = http.MultipartRequest('PUT', uri);
        multipartRequest.headers['Authorization'] = 'Bearer $_authToken';

        // Add text fields
        if (request.name != null) {
          multipartRequest.fields['name'] = request.name!;
        }
        if (request.description != null) {
          multipartRequest.fields['description'] = request.description!;
        }
        if (request.price != null) {
          multipartRequest.fields['price'] = request.price.toString();
        }
        if (request.discountedPrice != null) {
          multipartRequest.fields['discountedPrice'] = request.discountedPrice.toString();
        }
        if (request.stock != null) {
          multipartRequest.fields['stock'] = request.stock.toString();
        }
        if (request.category != null) {
          multipartRequest.fields['category'] = request.category!;
        }
        if (request.colors != null) {
          multipartRequest.fields['colors'] = jsonEncode(request.colors);
        }
        if (request.attributes != null) {
          multipartRequest.fields['attributes'] = jsonEncode(request.attributes);
        }
        if (request.sizes != null) {
          multipartRequest.fields['sizes'] = jsonEncode(request.sizes);
        }
        if (request.materials != null) {
          multipartRequest.fields['materials'] = jsonEncode(request.materials);
        }
        if (request.status != null) {
          multipartRequest.fields['status'] = request.status!;
        }
        if (request.image != null) {
          multipartRequest.fields['image'] = request.image!;
        }
        if (request.draft != null) {
          multipartRequest.fields['draft'] = request.draft.toString();
          print('   Sending draft value: ${request.draft.toString()}');
        }

        // ✅ IMPORTANT: Send images to delete
        if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
          multipartRequest.fields['imagesToDelete'] = jsonEncode(imagesToDelete);
          print('   Images to delete: $imagesToDelete');
        }

        // Add new images
        if (newImages != null) {
          for (var file in newImages) {
            final mimeType = _getMimeType(file.path);
            final multipartFile = await http.MultipartFile.fromPath(
              'images',
              file.path,
              contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
            );
            multipartRequest.files.add(multipartFile);
          }
        }

        print('📤 Sending multipart update request with fields:');
        multipartRequest.fields.forEach((key, value) {
          print('   $key: $value');
        });

        final streamedResponse = await multipartRequest.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Update product response status: ${response.statusCode}');
        print('Update product response body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return ProductResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMessage = errorData['message'] ?? 'Failed to update product';

          if (errorData['errors'] != null && errorData['errors'] is List) {
            final errors = errorData['errors'] as List;
            if (errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map && firstError['msg'] != null) {
                errorMessage = firstError['msg'];
              }
            }
          }

          return ProductResponse(
            success: false,
            message: errorMessage,
            error: errorData['error'],
          );
        }
      } else {
        // Regular JSON request (no new images)
        final body = request.toJson();

        print('📤 Sending JSON update request with body:');
        print(jsonEncode(body));

        final response = await client.put(
          uri,
          headers: _getHeaders(),
          body: jsonEncode(body),
        );

        print('Update product response status: ${response.statusCode}');
        print('Update product response body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return ProductResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMessage = errorData['message'] ?? 'Failed to update product';

          if (errorData['errors'] != null && errorData['errors'] is List) {
            final errors = errorData['errors'] as List;
            if (errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map && firstError['msg'] != null) {
                errorMessage = firstError['msg'];
              }
            }
          }

          return ProductResponse(
            success: false,
            message: errorMessage,
            error: errorData['error'],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Delete product image
  // Delete product image
  Future<ProductResponse> deleteProductImage(String productId, String imageId) async {
    try {
      // Fix: The URL should be /api/seller/products/deleteimage/PRODUCT_ID/IMAGE_ID
      final uri = Uri.parse(_buildUrl('${ApiConstants.deleteProductImage}/$productId/$imageId'));

      if (kDebugMode) {
        print('Delete image URL: $uri');
      }

      final response = await client.delete(
        uri,
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print('Delete image response status: ${response.statusCode}');
        print('Delete image response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to delete image',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product image: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }


  // Archive product (soft delete)
  Future<ProductResponse> archiveProduct(String productId) async {
    try {
      final response = await client.put(
        Uri.parse(_buildUrl('${ApiConstants.archiveProduct}/$productId')),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to archive product',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error archiving product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Delete product (permanent)
  Future<ProductResponse> deleteProduct(String productId) async {
    try {
      final response = await client.delete(
        Uri.parse(_buildUrl('${ApiConstants.deleteProduct}/$productId')),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to delete product',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get product statistics
  Future<ProductStatsResponse> getProductStats() async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getProductStats)),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductStatsResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductStatsResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get product stats',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product stats: $e');
      }
      return ProductStatsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Update stock
  Future<ProductResponse> updateStock(String productId, int stock) async {
    try {
      final response = await client.put(
        Uri.parse(_buildUrl('${ApiConstants.updateStock}/$productId')),
        headers: _getHeaders(),
        body: jsonEncode(UpdateStockRequest(stock: stock).toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to update stock',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating stock: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get products by category
  Future<ProductResponse> getProductsByCategory(
      String category, {
        int page = 1,
        int limit = 20,
      }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(_buildUrl('${ApiConstants.getProductsByCategory}/$category'))
          .replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get products by category',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting products by category: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get seller allowed categories
  Future<SellerCategoriesResponse> getSellerAllowedCategories() async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getSellerAllowedCategories)),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SellerCategoriesResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return SellerCategoriesResponse(
          success: false,
          categories: [],
          hasCategories: false,
          message: errorData['message'] ?? 'Failed to get categories',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting seller categories: $e');
      }
      return SellerCategoriesResponse(
        success: false,
        categories: [],
        hasCategories: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Publish a draft product
  Future<ProductResponse> publishProduct(String productId) async {
    try {
      final response = await client.put(
        Uri.parse(_buildUrl('${ApiConstants.publishProduct}/$productId')),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to publish product',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error publishing product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Unpublish product (convert back to draft)
  Future<ProductResponse> unpublishProduct(String productId) async {
    try {
      final response = await client.put(
        Uri.parse(_buildUrl('${ApiConstants.unpublishProduct}/$productId')),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ProductResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to unpublish product',
          error: errorData['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unpublishing product: $e');
      }
      return ProductResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Helper method to get MIME type
  String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
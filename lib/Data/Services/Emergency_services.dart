import 'dart:async';
import 'dart:convert';

import 'package:administration_emergency/Data/Models/EmergencyModel.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
class EmergencyServices {
  // Stream controller for emergency data
  final StreamController<List<Emergencymodel>> _emergencyStreamController = StreamController<List<Emergencymodel>>.broadcast();
  
  // List to store all emergencies
  List<Emergencymodel> _allEmergencies = [];
  
  // Selected filter types
  final Set<String> _selectedFilters = {};
  

  String _searchQuery = '';
  

  Set<String> get selectedFilters => _selectedFilters;
  

  Stream<List<Emergencymodel>> get emergencyStream => _emergencyStreamController.stream;
  
 
 
  
  // Initialize periodic fetching
  void startRealTimeUpdates(String type, {Duration refreshInterval = const Duration(seconds: 5)}) {
    // Initial fetch
    fetchEmergency(type);
    
    // Set up periodic fetching
    Timer.periodic(refreshInterval, (timer) {
      fetchEmergency(type);
    });
  }
  
  // Toggle a specific filter
  void toggleFilter(String type) {
    if (_selectedFilters.contains(type)) {
      _selectedFilters.remove(type);
    } else {
      _selectedFilters.add(type);
    }
    
    // Update the stream with filtered data
    _updateStream();
  }
  
  // Clear all filters
  void clearFilters() {
    _selectedFilters.clear();
    _updateStream();
  }
  
  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _updateStream();
  }
  
  // Fetch all emergencies from API
 Future<List<Emergencymodel>> fetchEmergency(String type) async {
  final uri = Uri.parse("https://nejda.onrender.com/api/emergency/$type");
  
  try {
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      
      if (jsonData is Map && jsonData.containsKey("data")) {
        final List<dynamic> emergencyList = jsonData["data"];
        
      
        _allEmergencies = emergencyList
            .map((item) => Emergencymodel.fromJson(item))
            .where((emergency) => emergency.Status == false) 
            .toList()
            .reversed
            .toList();
        
   
        _updateStream();
        
        return getFilteredEmergencies();
      } else {
        throw Exception("Unexpected JSON format");
      }
    } else {
      throw Exception('Failed to load emergencies: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching emergencies: $e");
    
 
    return [];
  }
}
  
  // Get filtered emergencies based on selected filters
  List<Emergencymodel> getFilteredEmergencies() {
    if (_selectedFilters.isEmpty) {
      return _searchEmergencies(_allEmergencies, _searchQuery);
    }
    
    return _searchEmergencies(
      _allEmergencies.where((emergency) => 
        _selectedFilters.contains(emergency.emergencyType)).toList(),
      _searchQuery
    );
  }
  
  // Search within filtered emergencies
  List<Emergencymodel> _searchEmergencies(List<Emergencymodel> emergencies, String query) {
    if (query.isEmpty) {
      return emergencies;
    }
    
    query = query.toLowerCase();
    return emergencies.where((emergency) =>
      emergency.nameUser.toLowerCase().contains(query) ||
      emergency.emergencyType.toLowerCase().contains(query)).toList();
  }
  
  // Update the stream with current filtered data
  void _updateStream() {
    if (!_emergencyStreamController.isClosed) {
      _emergencyStreamController.add(getFilteredEmergencies());
    }
  }
  

  Future<bool> confirmEmergency(String id_Emergency) async {
    final String url = "https://nejda.onrender.com/api/emergency/confirm/$id_Emergency";
    
    try {
      final response = await http.patch(
        Uri.parse(url),
      );
      
      if (response.statusCode == 200) {
        
        fetchEmergency(_allEmergencies.isNotEmpty ? 
                             _allEmergencies.first.emergencyType : "emergency");
        return true;
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
  
  
  Future<List<Emergencymodel>> getConfirmedEmergencies(String type) async {
  final uri = Uri.parse("https://nejda.onrender.com/api/emergency/allConfiremed");
  
  try {
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      
      if (jsonData is Map && jsonData.containsKey("data")) {
        final List<dynamic> emergencyList = jsonData["data"];
        
      
        List<Emergencymodel> confirmedEmergencies = emergencyList
            .map((item) => Emergencymodel.fromJson(item))
            .where((item) => item.Needs == type)
            .toList();
            
     
       
        if (_selectedFilters.isNotEmpty) {
          confirmedEmergencies = confirmedEmergencies
              .where((emergency) => _selectedFilters.contains(emergency.emergencyType))
              .toList();
        }
        
        // Apply search functionality
        if (_searchQuery.isNotEmpty) {
          String query = _searchQuery.toLowerCase();
          confirmedEmergencies = confirmedEmergencies
              .where((emergency) =>
                  emergency.nameUser.toLowerCase().contains(query) ||
                  emergency.emergencyType.toLowerCase().contains(query))
              .toList();
        }
         
        return confirmedEmergencies;
      } else {
        throw Exception("Unexpected JSON format");
      }
    } else {
      throw Exception('Failed to load confirmed emergencies: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching confirmed emergencies: $e");
    return [];
  }
}

  // Dispose resources
  void dispose() {
    _emergencyStreamController.close();
  }
}
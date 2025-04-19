import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nothing_clock/models/world_clock_data.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:provider/provider.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _debounce;

  Future<void> _searchCity(String query) async {
    if(query.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&accept-language=en');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'NothingClock/1.0 (chverenkool@gmail.com)',
        'Accept-Language': 'en'
      });

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body); 
        setState(() {
          _suggestions = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _errorMessage = "Failed to load cities. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _errorMessage = "Network error. Please check your connection.";
      });
    }
  }

  void _onSearchChanged(String query) {
    if(_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchCity(query);
    });
  }

  String _getCleanDisplayName(dynamic suggestion) {
    if (suggestion['address'] != null) {
      if (suggestion['address']['city'] != null) {
        return suggestion['address']['city'];
      } else if (suggestion['address']['town'] != null) {
        return suggestion['address']['town'];
      } else if (suggestion['address']['village'] != null) {
        return suggestion['address']['village'];
      } else if (suggestion['address']['state'] != null) {
        return suggestion['address']['state'];
      } else if (suggestion['address']['country'] != null) {
        return suggestion['address']['country'];
      }
    }
    
    String truncatedDisplayName = suggestion['display_name'].split(",")[0];
    return truncatedDisplayName;
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(itemBuilder: (context, index) {
      final suggestion = _suggestions[index];
      final worldClocksProvider = Provider.of<WorldClocksProvider>(context, listen: false);

      String displayName = _getCleanDisplayName(suggestion);
      
      return ListTile(
        title: Text(displayName),
        subtitle: Text(suggestion['display_name']),
        onTap: () async {
          WorldClockData worldClock = WorldClockData(
            currentFormattedTime: "00:00",
            utcTime: 0,
            longitude: double.parse(suggestion['lon']),
            latitude: double.parse(suggestion['lat']),
            displayName: displayName,
          );

          // Try to add the world clock and check if it's a duplicate
          bool added = await worldClocksProvider.addWorldClock(worldClock);
          
          if (!added) {
            // Show a snackbar if the location is already added
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${worldClock.displayName} is already added to your world clocks"),
                  duration: const Duration(seconds: 2),
                )
              );
            }
          } else {
            // Close the screen only if we successfully added the clock
            Navigator.of(context).pop();
          }
        },
      );
    }, itemCount: _suggestions.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Enter a city name',
          ),
          onChanged:(value) {
            _onSearchChanged(value);
          },
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : _suggestions.isNotEmpty 
                ? _buildSuggestionsList() 
                : const Center(child: Text("Search for a city")),
    );
  }
}
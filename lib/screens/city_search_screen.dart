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

  Timer? _debounce;

  Future<void> _searchCity(String query) async {
    if(query.isEmpty) {
      setState(() {
        _suggestions = [];
      });

      return;
    }

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'NothingClock/1.0 (chverenkool@gmail.com)',
      });

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body); 
        setState(() {
          _suggestions = data;
        });
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _onSearchChanged(String query) {
    if(_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchCity(query);
    });
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(itemBuilder: (context, index) {
      final suggestion = _suggestions[index];
      final worldClocksProvider = Provider.of<WorldClocksProvider>(context, listen: false);

      return ListTile(
        title: Text(suggestion['display_name']),
        onTap: () {

          String truncatedDisplayName = suggestion['display_name'].split(",")[0];
          //Load only the latitude, longitude and the display name
          WorldClockData worldClock = WorldClockData(
            currentFormattedTime: "00:00",
            utcTime: 0,
            longitude: double.parse(suggestion['lon']),
            latitude: double.parse(suggestion['lat']),
            displayName: truncatedDisplayName,
          );

          //The underlying code will take care of fetching the timezone data
          worldClocksProvider.addWorldClock(worldClock);
          Navigator.of(context).pop(suggestion);
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
      body: _suggestions.isNotEmpty ? _buildSuggestionsList() : const Center(child: Text("Search for a city")),
    );
  }
}
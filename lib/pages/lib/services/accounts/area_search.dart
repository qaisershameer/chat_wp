import 'package:flutter/material.dart';
import 'package:chat_wp/models/area.dart';
import 'package:chat_wp/services/accounts/area_service.dart';

class AreaDropdown extends StatefulWidget {
  @override
  _AreaDropdownState createState() => _AreaDropdownState();
}

class _AreaDropdownState extends State<AreaDropdown> {
  final AreaService _areaService = AreaService();

  List<Area> _areas = [];
  Area? _selectedArea;

  @override
  void initState() {
    super.initState();
    // _loadAreas();
  }

  // Future<void> _loadAreas() async {
  //   _subscription = _areaService.getAreasStream('qybFCCei14OMXvVNMVwGc0vGtpO2').listen((areas) {
  //     setState(() {
  //       _areas = areas;
  //       if (areas.isNotEmpty) {
  //         _selectedArea = areas[0]; // Set default selection
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Area>(
      value: _selectedArea,
      items: _areas.map((area) {
        return DropdownMenuItem<Area>(
          value: area,
          child: Text(area.name),
        );
      }).toList(),
      onChanged: (Area? newArea) {
        setState(() {
          _selectedArea = newArea;
        });
      },
      hint: const Text('Select an area'),
    );
  }
}

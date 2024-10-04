import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../GoogleSignIn_id.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../container.dart';

class LoginPageService {
  static final LoginPageService _instance = LoginPageService._internal();
  factory LoginPageService() => _instance;
  LoginPageService._internal();


  Future<void> getContactProfiles(int userId) async {
    const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
    final String url = '$baseUrl/users/$userId/contact-profiles';
    final prefs = await SharedPreferences.getInstance();
    final String? apiToken = prefs.getString('api_token');

    final headers = {
      'Authorization': 'Bearer $apiToken',
    };


    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic>? contactProfiles = json.decode(response.body) as List?;
        if (contactProfiles == null || contactProfiles.isEmpty) {
          print('No saved contacts found.');
          return;
        }

        final List<Map<String, dynamic>> simplifiedProfiles = contactProfiles.map((profile) {
          return {
            'id': profile['id'],
            'user_id': profile['user_id'],
            'name': profile['name'] ?? '',
            'email': profile['email'] ?? '',
            'address': profile['address'] ?? '',
            'website': profile['website'] ?? '',
            'date_of_birth': profile['date_of_birth'] ?? '',
            'notes': profile['notes'] ?? '',
            'created_at': profile['created_at'],
            'updated_at': profile['updated_at'],
            'phone_numbers': (profile['phone_numbers'] as List?)?.map((phone) => {
              'type': phone['type'],
              'number': phone['number'],
            }).toList() ?? [],
            'social_links': (profile['social_links'] as List?)?.map((link) => {
              'platform': link['platform'],
              'url': link['url'],
            }).toList() ?? [],
            'custom_fields': (profile['custom_fields'] as List?)?.map((field) => {
              'label': field['label'],
              'value': field['value'],
            }).toList() ?? [],
            'job_info': (profile['job_info'] as List?)?.map((job) => {
              'title': job['title'],
              'company': job['company'],
            }).toList() ?? [],
          };
        }).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('contact_profiles', json.encode(simplifiedProfiles));
        print('Contact profiles fetched and saved successfully');
      } else {
        print('Failed to fetch contact profiles: ${response.body}');
      }
    } catch (e) {
      print('Error fetching contact profiles: $e');
    }
  }

  Future<void> getSavedContacts(int userId) async {
    const String baseUrl = 'http://127.0.0.1:8000/api'; // For Local Development
    final String url = '$baseUrl/users/$userId/saved-contacts';
    final prefs = await SharedPreferences.getInstance();
    final String? apiToken = prefs.getString('api_token');

    final headers = {
      'Authorization': 'Bearer $apiToken',
    };


    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic>? savedContacts = json.decode(response.body) as List<dynamic>?;

        if (savedContacts == null || savedContacts.isEmpty) {
          print('No saved contacts found.');
          return;
        }

        final List<Map<String, dynamic>> simplifiedContacts = savedContacts.map((contact) {
          return {
            'id': contact['id'],
            'user_id': contact['user_id'],
            'name': contact['name'] ?? '',
            'email': contact['email'] ?? '',
            'address': contact['address'] ?? '',
            'website': contact['website'] ?? '',
            'date_of_birth': contact['date_of_birth'] ?? '',
            'notes': contact['notes'] ?? '',
            'profile_picture': contact['profile_picture'] ?? '',
            'created_at': contact['created_at'],
            'updated_at': contact['updated_at'],
            'phone_numbers': (contact['phone_numbers'] as List<dynamic>?)?.map((phone) => {
              'type': phone['type'],
              'number': phone['number'],
            }).toList() ?? [],
            'social_links': (contact['social_links'] as List<dynamic>?)?.map((link) => {
              'platform': link['platform'],
              'url': link['url'],
            }).toList() ?? [],
            'job_info': (contact['job_info'] as List<dynamic>?)?.map((job) => {
              'title': job['title'],
              'company': job['company'],
            }).toList() ?? [],
            'custom_fields': (contact['custom_fields'] as List<dynamic>?)?.map((field) => {
              'label': field['label'],
              'value': field['value'],
            }).toList() ?? [],
          };
        }).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_contacts', json.encode(simplifiedContacts));
        print('Saved contacts fetched and saved successfully');
      } else {
        print('Failed to fetch saved contacts: ${response.body}');
      }
    } catch (e) {
      print('Error fetching saved contacts: $e');
    }
  }

}
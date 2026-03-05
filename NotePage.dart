import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginPage.dart';
import 'AddNotePage.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  String? _profileImageUrl;
  String? _firstName;
  String? _secondName;
  String? _gender;
  String? _email;

  List<Map<String, dynamic>> _submittedNotes = [];

  final List<Map<String, dynamic>> _userAccounts = [
    {
      'name': 'John Doe',
      'email': 'john@example.com',
      'avatarColor': Colors.blue,
      'avatarText': 'JD',
    },
    {
      'name': 'Alice Smith',
      'email': 'alice@example.com',
      'avatarColor': Colors.pink,
      'avatarText': 'AS',
    },
    {
      'name': 'Bob Johnson',
      'email': 'bob@example.com',
      'avatarColor': Colors.green,
      'avatarText': 'BJ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadProfileData();
    _loadSubmittedNotes();
  }

  Future<void> _loadSubmittedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final submittedItemsList = prefs.getStringList('submitted_items') ?? [];

    List<Map<String, dynamic>> notes = [];

    for (var itemJson in submittedItemsList) {
      try {
        final Map<String, dynamic> noteData = json.decode(itemJson);
        notes.add(noteData);
      } catch (e) {
        continue;
      }
    }

    setState(() {
      _submittedNotes = notes;
    });
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profile_image');
      _firstName = prefs.getString('first_name');
      _secondName = prefs.getString('second_name');
      _gender = prefs.getString('gender');
      _email = prefs.getString('registered_email');
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_logged_in', false);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSharedNoteToSharePage(String noteTitle, List<dynamic> noteItems, double totalPrice, String sharedToUser, String? shareNote) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedItemsList = prefs.getStringList('shared_items') ?? [];

    final List<Map<String, dynamic>> itemsToSave = [];
    for (var item in noteItems) {
      itemsToSave.add({
        'name': item['name'],
        'price': item['price'],
        'note': item['note'] ?? '',
        'date': item['date'],
        'imageBase64': item['imageBase64'],
      });
    }

    final Map<String, dynamic> sharedData = {
      'noteTitle': noteTitle,
      'sharedTo': sharedToUser,
      'sharedTime': _formatDateTime(DateTime.now()),
      'totalItems': noteItems.length,
      'totalPrice': '${_formatPrice(totalPrice.toStringAsFixed(0))} MMK',
      'sharedBy': '${_firstName ?? ''} ${_secondName ?? ''}'.trim(),
      'sharedDate': DateTime.now().toIso8601String(),
      'shareNote': shareNote ?? '',
      'items': itemsToSave,
    };

    sharedItemsList.add(json.encode(sharedData));
    await prefs.setStringList('shared_items', sharedItemsList);
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  void _showProfilePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 3),
                        ),
                        child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.memory(
                            base64.decode(_profileImageUrl!.split(',').last),
                            width: 94,
                            height: 94,
                            fit: BoxFit.cover,
                          ),
                        )
                            : CircleAvatar(
                          radius: 47,
                          backgroundColor: Colors.blueGrey.shade800,
                          child: Icon(Icons.person, color: Colors.white, size: 50),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_firstName != null || _secondName != null)
                        Text(
                          '${_firstName ?? ''} ${_secondName ?? ''}'.trim(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (_gender != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _gender == 'Male' ? Icons.male : Icons.female,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _gender!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 12),
                      if (_email != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _email!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _showLogoutConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoteDetailsPopup(int noteIndex) {
    final noteData = _submittedNotes[noteIndex];
    final List<dynamic> noteItems = noteData['items'];
    final String noteTitle = noteData['title'];

    double totalPrice = 0;
    for (var item in noteItems) {
      try {
        String cleanedPrice = item['price'].replaceAll(RegExp(r'[^\d]'), '');
        double priceValue = double.tryParse(cleanedPrice) ?? 0;
        totalPrice += priceValue;
      } catch (e) {
        continue;
      }
    }

    DateTime submittedDate = DateTime.parse(noteData['submittedDate']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<dynamic> currentNoteItems = List.from(noteItems);

        return Dialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          noteTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _showShareSelectionDialog(noteTitle, noteItems, submittedDate, totalPrice),
                            icon: Icon(
                              Icons.share,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            tooltip: 'Share Note',
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blueAccent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Submitted: ${_formatDate(submittedDate)}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Card(
                    color: Colors.blueGrey.shade800,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Items',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                '${currentNoteItems.length}',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Price',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                '${_formatPrice(totalPrice.toStringAsFixed(0))} MMK',
                                style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ...currentNoteItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;

                    return Dismissible(
                      key: Key('${item['name']}_${item['date']}_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.blueGrey.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              'Delete Item',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${item['name']}"?',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        currentNoteItems.removeAt(index);
                        if (currentNoteItems.isEmpty) {
                          Navigator.pop(context);
                          _deleteNote(noteIndex);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Note deleted successfully'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          _updateNoteInSharedPreferences(noteIndex, currentNoteItems, noteTitle, noteData['submittedDate']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Item deleted successfully'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              item['imageBase64'] != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64.decode(item['imageBase64']),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${index + 1}. ${item['name']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${_formatPrice(item['price'])} MMK',
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    if (item['note'] != null && item['note'].isNotEmpty)
                                      Text(
                                        item['note'],
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Added: ${_formatDate(DateTime.parse(item['date']))}',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  bool? shouldDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.blueGrey.shade900,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text(
                                        'Delete Item',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete "${item['name']}"?',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldDelete == true) {
                                    currentNoteItems.removeAt(index);
                                    if (currentNoteItems.isEmpty) {
                                      Navigator.pop(context);
                                      _deleteNote(noteIndex);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Note deleted successfully'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      _updateNoteInSharedPreferences(noteIndex, currentNoteItems, noteTitle, noteData['submittedDate']);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Item deleted successfully'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade300,
                                  size: 24,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showShareSelectionDialog(noteTitle, currentNoteItems, submittedDate, totalPrice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      icon: Icon(Icons.share, size: 20),
                      label: Text(
                        'Share This Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showShareSelectionDialog(String noteTitle, List<dynamic> noteItems, DateTime submittedDate, double totalPrice) {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Share Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(
                  'Add a note to share (optional)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: noteController,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Type your note here...',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                ..._userAccounts.map((user) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _shareNoteContent(noteTitle, noteItems, submittedDate, totalPrice, user['name'], noteController.text.trim());
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: user['avatarColor'],
                            radius: 22,
                            child: Text(
                              user['avatarText'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user['email'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 15),
                Divider(color: Colors.blueGrey.shade700),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _shareNoteContent(noteTitle, noteItems, submittedDate, totalPrice, null, noteController.text.trim());
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.blueAccent,
                          size: 24,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            'Share via other apps',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blueAccent,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareNoteContent(String noteTitle, List<dynamic> noteItems, DateTime submittedDate, double totalPrice, String? sharedToUser, String shareNote) {
    String shareText = '📝 $noteTitle\n\n';
    shareText += '📅 Submitted: ${_formatDate(submittedDate)}\n';
    shareText += '📦 Total Items: ${noteItems.length}\n';
    shareText += '💰 Total Price: ${_formatPrice(totalPrice.toStringAsFixed(0))} MMK\n\n';

    if (shareNote.isNotEmpty) {
      shareText += '💬 Note: $shareNote\n\n';
    }

    shareText += '📋 Items List:\n';

    for (int i = 0; i < noteItems.length; i++) {
      var item = noteItems[i];
      shareText += '${i + 1}. ${item['name']} - ${_formatPrice(item['price'])} MMK\n';
      if (item['note'] != null && item['note'].isNotEmpty) {
        shareText += '   Note: ${item['note']}\n';
      }
    }

    if (sharedToUser != null) {
      shareText += '\n👤 Shared to: $sharedToUser';
      shareText += '\nShared from My Notes App';

      _saveSharedNoteToSharePage(noteTitle, noteItems, totalPrice, sharedToUser, shareNote);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $sharedToUser successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      shareText += '\nShared from My Notes App';
    }
  }

  double _calculateTotalPrice(List<dynamic> noteItems) {
    double totalPrice = 0;
    for (var item in noteItems) {
      try {
        String cleanedPrice = item['price'].replaceAll(RegExp(r'[^\d]'), '');
        double priceValue = double.tryParse(cleanedPrice) ?? 0;
        totalPrice += priceValue;
      } catch (e) {
        continue;
      }
    }
    return totalPrice;
  }

  Future<void> _updateNoteInSharedPreferences(int noteIndex, List<dynamic> updatedItems, String title, String submittedDate) async {
    final prefs = await SharedPreferences.getInstance();
    final submittedItemsList = prefs.getStringList('submitted_items') ?? [];

    if (noteIndex < submittedItemsList.length) {
      final Map<String, dynamic> updatedNoteData = {
        'items': updatedItems,
        'title': title,
        'submittedDate': submittedDate,
      };

      submittedItemsList[noteIndex] = json.encode(updatedNoteData);
      await prefs.setStringList('submitted_items', submittedItemsList);

      _loadSubmittedNotes();
    }
  }

  Future<void> _deleteNote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final submittedItemsList = prefs.getStringList('submitted_items') ?? [];

    if (index < submittedItemsList.length) {
      submittedItemsList.removeAt(index);
      await prefs.setStringList('submitted_items', submittedItemsList);

      setState(() {
        _submittedNotes.removeAt(index);
      });
    }
  }

  void _showDeleteNoteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this note?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteNote(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Note deleted successfully'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(String price) {
    try {
      String cleanedPrice = price.replaceAll(RegExp(r'[^\d]'), '');
      int priceValue = int.tryParse(cleanedPrice) ?? 0;
      return priceValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
    } catch (e) {
      return price;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        toolbarHeight: 70,
        title: Text(
          'Note Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                if (_firstName != null && _firstName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      _firstName!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: _showProfilePopup,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blueAccent,
                    child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(
                        base64.decode(_profileImageUrl!.split(',').last),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                        : CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blueGrey.shade800,
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey.shade900, Colors.black],
              ),
            ),
            child: _submittedNotes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    color: Colors.blueGrey.shade600,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No submitted notes yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Submit items from Add Note page',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _submittedNotes.length,
              itemBuilder: (context, index) {
                final noteData = _submittedNotes[index];
                final List<dynamic> note = noteData['items'];
                final String noteTitle = noteData['title'];
                DateTime submittedDate = DateTime.parse(noteData['submittedDate']);

                double totalPrice = _calculateTotalPrice(note);

                return Dismissible(
                  key: Key('note_${submittedDate.toIso8601String()}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.blueGrey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          'Delete Note',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete "$noteTitle"?',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _deleteNote(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Note deleted successfully'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () => _showNoteDetailsPopup(index),
                    child: Card(
                      color: Colors.blueGrey.shade800,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    noteTitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _showShareSelectionDialog(noteTitle, note, submittedDate, totalPrice),
                                      icon: Icon(
                                        Icons.share,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      tooltip: 'Share Note',
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.blueAccent, width: 1),
                                      ),
                                      child: Text(
                                        '${note.length} items',
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _showDeleteNoteConfirmationDialog(index),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade300,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Submitted: ${_formatDate(submittedDate)}',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  '${_formatPrice(totalPrice.toStringAsFixed(0))} MMK',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tap to view details',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.blueAccent,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 75,
              child: CustomPaint(
                painter: FooterPainter(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/share');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share, color: Colors.white, size: 20),
                          SizedBox(width: 5),
                          Text('Share',
                              style:
                              TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    SizedBox(width: 60),
                    InkWell(
                      onTap: () {
                        print('Note tapped');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.note, color: Colors.white, size: 20),
                          SizedBox(width: 5),
                          Text('Note',
                              style:
                              TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 38,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddNotePage()),
                  ).then((_) {
                    _loadSubmittedNotes();
                  });
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueAccent.shade200,
                        Colors.blueAccent.shade700
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, size: 30, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    Path path = Path();
    double mid = size.width / 2;
    double notchWidth = 38;
    double notchDepth = 40;

    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);

    path.lineTo(mid - notchWidth - 10, 0);

    path.cubicTo(
      mid - notchWidth,
      0,
      mid - (notchWidth * 1),
      notchDepth,
      mid,
      notchDepth,
    );
    path.cubicTo(
      mid + (notchWidth * 1),
      notchDepth,
      mid + notchWidth,
      0,
      mid + notchWidth + 10,
      0,
    );

    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
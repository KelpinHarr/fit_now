import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:fit_now/ui/chat.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  final String email;
  final String? name;
  const HomePage({super.key, required this.email, this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _name = '';

  @override
  void initState(){
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDocs = await firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();
      if (userDocs.docs.isNotEmpty){
        final user = userDocs.docs.first;
        final name = user['name'];

        setState(() {
          _name = name;
        });
      }
    }
    catch(e){

    }
  }

  void _showCategoryDialog(BuildContext context) {
    // Peta untuk menyimpan status setiap checkbox
    Map<String, bool> selectedCategories = {
      'Upper Body': false,
      'Arms & Shoulder': false,
      'Chest': false,
      'Back': false,
      'Lower Body': false,
      'Glutes & Hamstring': false,
      'Core Body': false,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blue, // Warna biru seperti pada gambar
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...selectedCategories.keys.map((category) {
                      return CheckboxListTile(
                        title: Text(
                          category,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: selectedCategories[category], // Nilai dinamis
                        onChanged: (bool? value) {
                          setState(() {
                            selectedCategories[category] = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.orange,
                        checkColor: Colors.white,
                      );
                    }).toList(),
                    SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logika untuk submit pilihan
                          print("Selected Categories: $selectedCategories");
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Warna tombol submit
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.black, // Warna teks pada tombol
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30, left: 20),
              child: _name == '' 
                ? Text(
                    'Welcome, ${widget.name}!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'ReadexPro-Medium',
                      fontWeight: FontWeight.bold
                    ),
                  )
                :
                Text(
                  'Welcome, ${_name}!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'ReadexPro-Medium',
                    fontWeight: FontWeight.bold
                  ),
                ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'It\'s a new day to achieve new milestones.\nLet\'s get moving!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
            ),
            SizedBox(height: 35),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Your previous session',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'There\'s no previous session',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'OpenSans'
                ),
              ),
            ), //sementara sblm nambah list view
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Ready for a workout designed just for you? Our AI\ncan create custom plans based on your goals',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ReadexPro-Medium'
                ),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: (){
                    _showCategoryDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.fromHeight(55)
                  ),
                  child: Text(
                    'Choose your target muscle group',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ReadexPro-Medium'
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ChatPage(email: widget.email)), 
            );
          },
          backgroundColor: darkBlue,
          child: Icon(
            Iconsax.messages_1, 
            color: _currentIndex == 2 ? orange : white,
            size: 35,
          ),
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex, 
        onTabSelected: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        selectedColor: orange,
        unselectedColor: white,
        backgroundColor: darkBlue,
        email: widget.email,
      )
    );
  }
}
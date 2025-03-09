import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Flashcard {
  String title;
  List<String> sentences;

  Flashcard({required this.title, required this.sentences});
}

class Library {
  static List<Flashcard> flashcards = [];
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: WelcomeScreen(),
    );
  }
}

// a) The welcome screen of the Application.

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, size: 100, color: Colors.yellow),
            SizedBox(height: 20),
            Text(
              'Welcome to KeyPoint',
              style: TextStyle( fontWeight: FontWeight.bold,color: Colors.white, fontSize: 22,),
            ),
          ],
        ),
      ),
    );
  }
}

// b) This is the home Screen.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KeyPoint')),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return LibraryScreen();
      case 1:
        return HomeScreenContent();
      case 2:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}

// c) Add the flashcard Screen.

class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              _showFlashcardTitleDialog(context);
            },
            child: Text('Add Flashcard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // d) Entering the FlashCard Title

  Future<void> _showFlashcardTitleDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Flashcard Title'),
          content: TextField(controller: controller),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParagraphScreen(flashcardTitle: controller.text),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class ParagraphScreen extends StatefulWidget {
  final String flashcardTitle;

  ParagraphScreen({required this.flashcardTitle});

  @override
  _ParagraphScreenState createState() => _ParagraphScreenState();
}

class _ParagraphScreenState extends State<ParagraphScreen> {
  TextEditingController paragraphController = TextEditingController();
  List<String> sentences = [];
  int currentSentenceIndex = 0;

  // e) The screen where the paragraph has been inserted.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.flashcardTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3), // Set the background color with opacity
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: paragraphController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Enter Paragraph'),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _processParagraph();
              },

              // f) The Paragraph will then be Processed.

              child: Text('Process Paragraph'),
            ),
            SizedBox(height: 16),
            if (sentences.isNotEmpty)
              Column(
                children: [
                  Text(
                    sentences[currentSentenceIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showPreviousSentence();
                        },

                        // g) The Previous page button.

                        child: Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showNextSentence();
                        },

                        // h) The Next page button.

                        child: Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _processParagraph() {
    String paragraph = paragraphController.text;
    List<String> extractedSentences = paragraph.split('. ');
    sentences.clear();
    sentences.addAll(extractedSentences);
    currentSentenceIndex = 0;

    // i) The new FlashCard Screen is shown.

    Flashcard newFlashcard = Flashcard(
      title: widget.flashcardTitle,
      sentences: sentences,
    );

    Library.flashcards.add(newFlashcard);

    // Navigate to the LibraryScreen and replace the current route
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LibraryScreen()),
    );
  }

  void _showNextSentence() {
    if (currentSentenceIndex < sentences.length - 1) {
      setState(() {
        currentSentenceIndex++;
      });
    }
  }

  void _showPreviousSentence() {
    if (currentSentenceIndex > 0) {
      setState(() {
        currentSentenceIndex--;
      });
    }
  }
}

// j) The library Screen is shown.

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library')),
      body: ListView.builder(
        itemCount: Library.flashcards.length,
        itemBuilder: (context, index) {
          return FlashcardItem(flashcard: Library.flashcards[index]);
        },
      ),
    );
  }
}

class FlashcardItem extends StatefulWidget {
  final Flashcard flashcard;

  FlashcardItem({required this.flashcard});

  @override
  _FlashcardItemState createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: isHovered ? 10.0 : 0.0,
              spreadRadius: isHovered ? 2.0 : 0.0,
            ),
          ],
          color: Colors.pink[50],
        ),
        child: ListTile(
          title: Text(widget.flashcard.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.brown,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardListScreen(flashcard: widget.flashcard),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleHover(bool hover) {
    setState(() {
      isHovered = hover;
    });
  }
}

// k) This screen will be List all the flashcards.

class FlashcardListScreen extends StatelessWidget {
  final Flashcard flashcard;

  FlashcardListScreen({required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(flashcard.title)),
      body: FlashcardScreen(flashcard: flashcard),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;

  FlashcardScreen({required this.flashcard});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentFlashcardIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade200, Colors.pink.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                widget.flashcard.sentences[currentFlashcardIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Page ${currentFlashcardIndex + 1} of ${widget.flashcard.sentences.length}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showPreviousFlashcard();
                },
                child: Text('Previous'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showNextFlashcard();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNextFlashcard() {
    if (currentFlashcardIndex < widget.flashcard.sentences.length - 1) {
      setState(() {
        currentFlashcardIndex++;
      });
    }
  }

  void _showPreviousFlashcard() {
    if (currentFlashcardIndex > 0) {
      setState(() {
        currentFlashcardIndex--;
      });
    }
  }
}

// l) This screen will show the Anonymous Profile once logged out.

class AnonymousProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anonymous Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple, // Placeholder for anonymous profile image
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Anonymous',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'No detail',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement log in functionality
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text('Log In'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// m) This is the profile Screen.

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://example.com/profile_picture.jpg'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLoggedIn ? 'Izzah Azizul' : 'Anonymous',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.verified, color: Colors.green),
                ],
              ),
              SizedBox(height: 8),
              Text(
                isLoggedIn ? 'Student' : 'No detail',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.favorite_border),
                      SizedBox(height: 8),
                      Text('Likes', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.comment_outlined),
                      SizedBox(height: 8),
                      Text('Comments', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.share_outlined),
                      SizedBox(height: 8),
                      Text('Shares', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (isLoggedIn) {
                    // Implement edit profile functionality
                  } else {
                    // Navigate to AnonymousProfilePage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AnonymousProfilePage()),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isLoggedIn ? Icons.edit : Icons.login),
                    SizedBox(width: 8),
                    Text(isLoggedIn ? 'Edit Profile' : 'Log In'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoggedIn = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully Logged Out'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Navigate to AnonymousProfilePage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AnonymousProfilePage()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
  }
}
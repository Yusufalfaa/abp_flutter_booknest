import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase
cred = credentials.Certificate("lib/services/adminSDK.json")  # Replace with actual path
firebase_admin.initialize_app(cred)

db = firestore.client()

# Load JSON file with UTF-8 encoding
with open("assets/books.json", "r", encoding="utf-8") as file:
    books = json.load(file)

# Upload to Firestore using ISBN-13 as ID
total_books = len(books)  # Get total books
print(f"Starting upload of {total_books} books...")

for index, book in enumerate(books, start=1):
    if "isbn13" in book and book["isbn13"]:  # Ensure ISBN-13 exists
        doc_ref = db.collection("books").document(str(book["isbn13"]))  # Use ISBN-13 as ID
        doc_ref.set(book)
        print(f"✅ Uploaded {index}/{total_books}: {book.get('title', 'Unknown Title')}")
    else:
        print(f"⚠️ Skipping book {index}/{total_books} due to missing ISBN-13")

print("🎉 All books uploaded successfully!")

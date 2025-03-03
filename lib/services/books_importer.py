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

# Required fields (modify if needed)
REQUIRED_FIELDS = ["isbn13", "title", "authors", "categories", "thumbnail", "description"]

total_books = len(books)
skipped_books = 0
uploaded_books = 0

print(f"Starting upload of {total_books} books...")

for index, book in enumerate(books, start=1):
    # Check if any required field is missing or empty
    if any(not book.get(field) for field in REQUIRED_FIELDS):
        print(f"⚠️ Skipping book {index}/{total_books} due to missing required fields.")
        skipped_books += 1
        continue
    
    # Upload to Firestore
    doc_ref = db.collection("books").document(str(book["isbn13"]))  # Use ISBN-13 as ID
    doc_ref.set(book)
    uploaded_books += 1
    print(f"✅ Uploaded {index}/{total_books}: {book['title']}")

print(f"🎉 Upload completed! {uploaded_books} books uploaded, {skipped_books} books skipped.")

import firebase_admin
from firebase_admin import credentials, firestore
import json
import random

# Initialize Firebase
cred = credentials.Certificate("lib/services/adminSDK.json")  # Replace with actual path
firebase_admin.initialize_app(cred)

db = firestore.client()

# Load JSON file with UTF-8 encoding
with open("assets/books.json", "r", encoding="utf-8") as file:
    books = json.load(file)

# Required fields (modify if needed)
REQUIRED_FIELDS = ["isbn13", "title", "authors", "categories", "thumbnail", "description"]

# Filter valid books (those that contain all required fields)
valid_books = [book for book in books if all(book.get(field) for field in REQUIRED_FIELDS)]

# Randomly select 500 books
selected_books = random.sample(valid_books, min(500, len(valid_books)))

total_books = len(selected_books)
uploaded_books = 0

print(f"📚 Starting upload of {total_books} random books...")

for index, book in enumerate(selected_books, start=1):
    # Upload to Firestore
    doc_ref = db.collection("books").document(str(book["isbn13"]))  # Use ISBN-13 as ID
    doc_ref.set(book)
    uploaded_books += 1
    print(f"✅ Uploaded {index}/{total_books}: {book['title']}")

print(f"🎉 Upload completed! {uploaded_books} books uploaded.")

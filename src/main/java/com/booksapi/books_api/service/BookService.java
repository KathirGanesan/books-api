package com.booksapi.books_api.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.booksapi.books_api.exception.BookNotFoundException;
import com.booksapi.books_api.model.Book;

@Service
public class BookService {

    private final List<Book> books = new ArrayList<>();
    private int currentId = 1;

    public List<Book> getAllBooks() {
        return books;
    }

    public Book getBookById(Integer id) {
        return books.stream()
                .filter(book -> book.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new BookNotFoundException("Book not found with id: " + id));
    }

    public Book createBook(Book book) {
        book.setId(currentId++);
        books.add(book);
        return book;
    }

    public Book updateBook(Integer id, Book bookDetails) {
        Book book = getBookById(id);
        book.setTitle(bookDetails.getTitle());
        book.setAuthor(bookDetails.getAuthor());
        book.setIsbn(bookDetails.getIsbn());
        book.setPublishedYear(bookDetails.getPublishedYear());
        return book;
    }

    public void deleteBook(Integer id) {
        Book book = getBookById(id);
        books.remove(book);
    }
}
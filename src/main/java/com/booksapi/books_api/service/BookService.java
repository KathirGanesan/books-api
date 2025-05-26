package com.booksapi.books_api.service;

import com.booksapi.books_api.exception.BookNotFoundException;
import com.booksapi.books_api.model.Book;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Service
public class BookService {
    private final ConcurrentMap<Integer, Book> books = new ConcurrentHashMap<>();
    private final AtomicInteger idGenerator = new AtomicInteger();

    public List<Book> getAllBooks() {
        log.debug("Fetching all books (count={})", books.size());
        return List.copyOf(books.values());
    }

    public Book getBookById(int id) {
        log.debug("Looking up book with id={}", id);
        Book book = books.get(id);
        if (book == null) {
            log.warn("Book not found for id={}", id);
            throw new BookNotFoundException("Book not found with id: " + id);
        }
        log.info("Found book: {} → {}", id, book.getTitle());
        return book;
    }

    public Book createBook(Book book) {
        int newId = idGenerator.incrementAndGet();
        book.setId(newId);
        books.put(newId, book);
        log.info("Created book id={} title='{}'", newId, book.getTitle());
        return book;
    }

    public Book updateBook(int id, Book details) {
        log.debug("Updating book id={} with {}", id, details);
        return books.compute(id, (key, existing) -> {
            if (existing == null) {
                log.warn("Cannot update, no book found with id={}", id);
                throw new BookNotFoundException("Book not found with id: " + id);
            }
            existing.setTitle(details.getTitle());
            existing.setAuthor(details.getAuthor());
            existing.setIsbn(details.getIsbn());
            existing.setPublishedYear(details.getPublishedYear());
            log.info("Updated book id={} → title='{}'", id, existing.getTitle());
            return existing;
        });
    }

    public void deleteBook(int id) {
        log.debug("Deleting book with id={}", id);
        if (books.remove(id) == null) {
            log.warn("Cannot delete, no book found with id={}", id);
            throw new BookNotFoundException("Book not found with id: " + id);
        }
        log.info("Deleted book id={}", id);
    }
}

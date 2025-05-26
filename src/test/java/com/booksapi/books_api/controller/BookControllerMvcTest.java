package com.booksapi.books_api.controller;

import com.booksapi.books_api.exception.BookNotFoundException;
import com.booksapi.books_api.model.Book;
import com.booksapi.books_api.service.BookService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(BookController.class)
class BookControllerMvcTest {

    @Autowired
    private MockMvc mvc;

    @MockBean
    private BookService bookService;

    private final ObjectMapper mapper = new ObjectMapper();

    private String asJson(Object o) throws Exception {
        return mapper.writeValueAsString(o);
    }

    /*────────────── POST /api/books ──────────────*/
    @Nested
    @DisplayName("POST /api/books")
    class CreateBook {
        @Test
        @DisplayName("returns 201 and body when book is created")
        void shouldCreateBook() throws Exception {
            Book payload = new Book(null, "Clean Code", "Robert C. Martin", "9780132350884", 2008);
            Book saved   = new Book(1,    "Clean Code", "Robert C. Martin", "9780132350884", 2008);

            given(bookService.createBook(any(Book.class))).willReturn(saved);

            mvc.perform(post("/api/books")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(asJson(payload)))
               .andExpect(status().isCreated())
               .andExpect(content().contentType(MediaType.APPLICATION_JSON))
               .andExpect(jsonPath("$.id").value(1))
               .andExpect(jsonPath("$.title").value("Clean Code"));

            Mockito.verify(bookService).createBook(any(Book.class));
        }

        @Test
        @DisplayName("returns 400 when validation fails (missing title)")
        void shouldFailValidation() throws Exception {
            Book invalid = new Book(null, "", "Anonymous", "123", 2025);

            mvc.perform(post("/api/books")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(asJson(invalid)))
               .andExpect(status().isBadRequest())
               .andExpect(jsonPath("$.status").value(400))
               .andExpect(jsonPath("$.timestamp").exists())
               .andExpect(jsonPath("$.errors", hasSize(greaterThanOrEqualTo(1))));
        }
    }

    /*────────────── GET /api/books ──────────────*/
    @Test
    @DisplayName("GET /api/books returns list of books")
    void shouldReturnAllBooks() throws Exception {
        Book b = new Book(1, "Test", "Tester", "1234", 2024);
        given(bookService.getAllBooks()).willReturn(List.of(b));

        mvc.perform(get("/api/books"))
           .andExpect(status().isOk())
           .andExpect(jsonPath("$[0].id").value(1));
    }

    /*────────────── GET /api/books/{id} ──────────────*/
    @Test
    @DisplayName("GET /api/books/{id} returns 404 when not found")
    void shouldReturn404ForMissingBook() throws Exception {
        given(bookService.getBookById(99))
            .willThrow(new BookNotFoundException("Book not found with id: 99"));

        mvc.perform(get("/api/books/99"))
           .andExpect(status().isNotFound())
           .andExpect(jsonPath("$.status").value(404))
           .andExpect(jsonPath("$.timestamp").exists())
           .andExpect(jsonPath("$.errors[0]", containsString("99")));
    }

    /*────────────── PATCH /api/books/{id} ──────────────*/
    @Test
    @DisplayName("PATCH /api/books/{id} updates book and returns 200")
    void shouldUpdateBook() throws Exception {
        Book update = new Book(null, "Refactoring", "Martin Fowler", "9780201485677", 1999);
        Book saved  = new Book(1, "Refactoring", "Martin Fowler", "9780201485677", 1999);

        given(bookService.updateBook(eq(1), any(Book.class))).willReturn(saved);

        mvc.perform(patch("/api/books/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(asJson(update)))
           .andExpect(status().isOk())
           .andExpect(jsonPath("$.title").value("Refactoring"));
    }

    /*────────────── DELETE /api/books/{id} ──────────────*/
    @Test
    @DisplayName("DELETE /api/books/{id} returns 204")
    void shouldDeleteBook() throws Exception {
        mvc.perform(delete("/api/books/1"))
           .andExpect(status().isNoContent());

        Mockito.verify(bookService).deleteBook(1);
    }

    /*────────────── Health check ──────────────*/
    @Test
    @DisplayName("GET /api/books/health returns OK")
    void healthCheck() throws Exception {
        mvc.perform(get("/api/books/health"))
           .andExpect(status().isOk())
           .andExpect(content().string("OK"));
    }
}

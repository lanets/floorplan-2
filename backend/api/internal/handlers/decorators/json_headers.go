package decorators

import (
	"net/http"
)

// JsonHeaders adds the Content-Type application/json header to the request.
// It adds the header before running the handler. Otherwise, it would be too
// late to add headers.
func JsonHeaders(h http.HandlerFunc) http.HandlerFunc {
	handler := func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		h(w, r)
	}
	return handler
}

package product

import (
	"encoding/json"
	"flutter_shop_app/app"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"strconv"

	"github.com/julienschmidt/httprouter"
)

// NewHandler returns a new Handler
func NewHandler(app app.State) *Handler {
	store := dataStore{db: app.Database}
	return &Handler{app: app, store: store}
}

// Handler contains the HTTP endpoint handlers
type Handler struct {
	app   app.State
	store dataStore
}

func (handler *Handler) parseProduct(reqBody io.ReadCloser) (*Product, error) {
	body, err := ioutil.ReadAll(reqBody)
	defer reqBody.Close()
	if err != nil {
		return nil, err
	}
	product := &Product{}
	err = json.Unmarshal(body, product)
	if err != nil {
		return nil, err
	}
	return product, nil
}

// Get returns all saved products
func (handler *Handler) Get(res http.ResponseWriter, req *http.Request, _ httprouter.Params) {
	products, err := handler.store.getAll()
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(res, err)
		return
	}
	data, err := json.Marshal(products)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(res, err)
		return
	}
	res.WriteHeader(http.StatusOK)
	fmt.Fprintln(res, string(data))
}

// GetByID returns a product based on its ID
func (handler *Handler) GetByID(res http.ResponseWriter, req *http.Request, params httprouter.Params) {
	id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
	if err != nil {
		if err != nil {
			res.WriteHeader(http.StatusInternalServerError)
			fmt.Fprint(res, err)
			return
		}
	}
	products, err := handler.store.getByID(id)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(res, err)
		return
	}
	data, err := json.Marshal(products)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(res, err)
		return
	}
	res.WriteHeader(http.StatusOK)
	fmt.Fprintln(res, string(data))
}

// Post saves a new product
func (handler *Handler) Post(res http.ResponseWriter, req *http.Request, _ httprouter.Params) {
	newProduct, err := handler.parseProduct(req.Body)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(res, err)
		return
	}
	id, err := handler.store.add(*newProduct)
	if err != nil {
		res.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(res, err)
		return
	}
	res.WriteHeader(http.StatusOK)
	fmt.Fprintln(res, id)
}
bundle install
rails db:create
rails db:migrate
rails db:seed


# Online Library System

This is a RESTful API for an online books library system, where users can borrow books and magazines based on their subscription plans.

### Models
- **User**: Manages user data including `name`, `email`, `age`, and `subscription_plan`.
  - `has_many :orders` association.
- **Item**: Represents items in the library with attributes like `title`, `genre`, and `item_type` (book or magazine).
  - `item_type` is an enum: `book` or `magazine`.
  - `has_many :orders` association.
- **Order**: Represents the order made by a user.
  - `belongs_to :user` and `belongs_to :item` associations.
  - Includes a `status` attribute (`borrowed`, `returned`, etc.).

### Controllers
- **OrdersController**: Manages the creation and updating of orders.
  - `create`: Handles the creation of a new order.
    - Fetches the `user` and `item` based on provided parameters.
    - Checks if the user has reached the maximum transactions.
    - Checks if the item is already borrowed.
    - Checks if the user's subscription plan allows borrowing the item.
    - Creates the order with status as `'borrowed'` if all conditions are met.
    - Renders success or error messages accordingly.
  - `update`: Handles the updating of orders when items are returned.
    - Fetches the `user` and `items` based on provided parameters.
    - Finds the borrowed items for the user.
    - Updates the status of each borrowed item to `'returned'`.
    - Renders a success message if items are returned.

### Usage
- Ensure you have Rails installed.
- Clone the repository.
- Run `bundle install` to install dependencies.
- Set up your database (`rails db:create`, `rails db:migrate`).
- Use Postman or similar tool to send requests to the API endpoints.

### API Endpoints
- **Create Order**:
  - POST `/orders`
  - Request Body:
    ```json
    {
      "order": {
        "user_id": "user_id_here",
        "item_id": "item_id_here"
      }
    }
    ```
- **Return Items**:
  - PUT `/returns`
  - Request Body:
    ```json
    {
      "item_ids": ["item_id_1", "item_id_2"]
    }
    ```

### Constraints
- Users can perform a maximum of 10 transactions in a month.
- Books with certain genres have age constraints.
- Each item can only be borrowed once at a time.

# POS API – Tài liệu hướng dẫn sử dụng

> **Repo:** `api` | **.NET 6** | **PostgreSQL** | **JWT Auth**

---

## 1. Tổng quan

| Thông tin | Giá trị |
|---|---|
| Base URL | `http://interview.geneat.pro` |
| API Version | `v1` → `/api/v1/...` |
| Auth | JWT Bearer Token |
| Content-Type | `application/json` |
| Database | PostgreSQL |
| Framework | .NET 6 – ASP.NET Core |

**Cách gắn token vào request:**
```
Authorization: Bearer <your_token_here>
```

---

## 2. Danh sách Modules

| # | Module | Base Path | Mô tả |
|---|---|---|---|
| 1 | Authentication | `/api/v1/authentication` | Đăng ký, đăng nhập, logout |
| 2 | Category | `/api/v1/categories` | Danh mục sản phẩm |
| 3 | Product | `/api/v1/products` | Sản phẩm |
| 4 | Customer | `/api/v1/customers` | Khách hàng |
| 5 | Order | `/api/v1/orders` | Đơn hàng + thống kê |
| 6 | Order Items | `/api/v1/order-items` | Chi tiết đơn hàng |
| 7 | Price History | `/api/v1/product-price-histories` | Lịch sử giá sản phẩm |
| 8 | User (IDM) | `/api/v1/idm/users` | Quản lý người dùng |
| 9 | Role (IDM) | `/api/v1/idm/roles` | Nhóm quyền |
| 10 | Right (IDM) | `/api/v1/idm/rights` | Quyền hệ thống |
| 11 | Right Map Role | `/api/v1/idm/right-map-role` | Gán quyền vào nhóm |

---

## 3. Authentication

### 3.1 Đăng ký tài khoản

```
POST /api/v1/authentication/register
🔓 Public
```

**Request Body:**

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `name` | string | ✅ | Họ tên |
| `phoneNumber` | string | ✅ | 10 chữ số |
| `email` | string | | Email hợp lệ |
| `password` | string | ✅ | Mật khẩu |
| `confirmPassword` | string | ✅ | Nhập lại mật khẩu |
| `gender` | int | | `0`=Unknown, `1`=Male, `2`=Female |

```js
fetch('http://localhost:8089/api/v1/authentication/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'Nguyễn Văn A',
    phoneNumber: '0901234567',
    email: 'nguyenvana@gmail.com',
    password: '123456',
    confirmPassword: '123456',
    gender: 1
  })
})
```

---

### 3.2 Đăng nhập – Lấy JWT Token

```
POST /api/v1/authentication/jwt/login
🔓 Public
```

**Request Body:**

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `phoneNumber` | string | ✅ | Số điện thoại |
| `password` | string | ✅ | Mật khẩu |
| `rememberMe` | bool | | Kéo dài thời gian sống token |
| `deviceToken` | string | | Firebase device token (push notification) |

```js
const res = await fetch('http://localhost:8089/api/v1/authentication/jwt/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    phoneNumber: '0901234567',
    password: '123456',
    rememberMe: true
  })
});
const data = await res.json();
const TOKEN = data.data.tokenString; // ← dùng token này cho các API tiếp theo
```

**Response:**
```json
{
  "isSuccess": true,
  "message": "Đăng nhập thành công",
  "data": {
    "userId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tokenString": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "issuedAt": "2024-01-01T00:00:00Z",
    "expiresAt": "2024-04-10T00:00:00Z",
    "roleListCode": ["ADMIN"],
    "rights": ["PRODUCT.VIEW", "ORDER.ADD"]
  }
}
```

---

### 3.3 Đăng xuất

```
POST /api/v1/authentication/logout
🔒 Bearer Token
```

**Query Parameter:**

| Field | Type | Mô tả |
|---|---|---|
| `isMobileDevice` | string | `"true"` nếu là thiết bị mobile |

---

### 3.4 Lấy thông tin token hiện tại

```
POST /api/v1/authentication/jwt/info
🔒 Bearer Token
```

Trả về thông tin user đang đăng nhập từ token.

---

## 4. Category – Danh mục sản phẩm

> Tất cả endpoint đều yêu cầu 🔒 Bearer Token

### 4.1 Tạo danh mục

```
POST /api/v1/categories
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `name` | string | ✅ | Tên danh mục |
| `description` | string | | Mô tả |

```js
fetch('http://localhost:8089/api/v1/categories', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TOKEN}`
  },
  body: JSON.stringify({ name: 'Đồ uống', description: 'Các loại nước uống' })
})
```

---

### 4.2 Danh sách danh mục (phân trang)

```
GET /api/v1/categories
```

| Query Param | Type | Default | Mô tả |
|---|---|---|---|
| `page` | int | `1` | Số trang |
| `size` | int | `20` | Số bản ghi mỗi trang |
| `sort` | string | `-CreatedOnDate` | VD: `Name` hoặc `-Name` (desc) |
| `filter` | string | `{}` | JSON filter object (URL-encoded) |

```js
// Lấy trang 1, 10 bản ghi
fetch('http://localhost:8089/api/v1/categories?page=1&size=10', {
  headers: { 'Authorization': `Bearer ${TOKEN}` }
})
```

---

### 4.3 Chi tiết danh mục

```
GET /api/v1/categories/{id}
```

```js
fetch('http://localhost:8089/api/v1/categories/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', {
  headers: { 'Authorization': `Bearer ${TOKEN}` }
})
```

---

### 4.4 Cập nhật danh mục

```
PUT /api/v1/categories/{id}
```

Body giống tạo mới: `name`, `description`.

---

### 4.5 Xóa danh mục

```
DELETE /api/v1/categories/{id}
```

---

## 5. Product – Sản phẩm

> Tất cả endpoint đều yêu cầu 🔒 Bearer Token

### 5.1 Tạo sản phẩm

```
POST /api/v1/products
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `name` | string | ✅ | Tên sản phẩm |
| `categoryId` | guid | ✅ | ID danh mục |
| `currentPrice` | decimal | ✅ | Giá hiện tại |
| `stockQuantity` | int | ✅ | Số lượng tồn kho |

```js
fetch('http://localhost:8089/api/v1/products', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TOKEN}`
  },
  body: JSON.stringify({
    name: 'Coca Cola 330ml',
    categoryId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
    currentPrice: 15000,
    stockQuantity: 100
  })
})
```

---

### 5.2 Danh sách sản phẩm (phân trang)

```
GET /api/v1/products
```

| Query Param | Type | Default | Mô tả |
|---|---|---|---|
| `page` | int | `1` | Số trang |
| `size` | int | `20` | Số bản ghi |
| `sort` | string | `-CreatedOnDate` | Sắp xếp |
| `filter` | string | `{}` | Hỗ trợ field: `categoryId` |

```js
// Lọc theo danh mục
const filter = encodeURIComponent(JSON.stringify({ categoryId: 'xxxxxxxx-...' }));
fetch(`http://localhost:8089/api/v1/products?filter=${filter}`, {
  headers: { 'Authorization': `Bearer ${TOKEN}` }
})
```

---

### 5.3 Chi tiết / 5.4 Cập nhật / 5.5 Xóa sản phẩm

```
GET    /api/v1/products/{id}
PUT    /api/v1/products/{id}   ← body giống tạo mới
DELETE /api/v1/products/{id}
```

---

## 6. Customer – Khách hàng

> Tất cả endpoint đều yêu cầu 🔒 Bearer Token

### 6.1 Tạo khách hàng

```
POST /api/v1/customers
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `name` | string | ✅ | Tên khách hàng |
| `phoneNumber` | string | ✅ | Số điện thoại |

```js
fetch('http://localhost:8089/api/v1/customers', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TOKEN}`
  },
  body: JSON.stringify({ name: 'Trần Thị B', phoneNumber: '0987654321' })
})
```

---

### 6.2 – 6.5 CRUD Khách hàng

```
GET    /api/v1/customers           ← phân trang (page, size, sort, filter)
GET    /api/v1/customers/{id}
PUT    /api/v1/customers/{id}      ← body: name, phoneNumber
DELETE /api/v1/customers/{id}
```

---

## 7. Order – Đơn hàng

> Tất cả endpoint đều yêu cầu 🔒 Bearer Token

### 7.1 Tạo đơn hàng

```
POST /api/v1/orders
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `customerId` | guid | ✅ | ID khách hàng |
| `items` | array | ✅ | Danh sách sản phẩm |
| `items[].orderId` | guid | ✅ | Để `00000000-0000-0000-0000-000000000000` khi tạo mới |
| `items[].productId` | guid | ✅ | ID sản phẩm |

```js
fetch('http://localhost:8089/api/v1/orders', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TOKEN}`
  },
  body: JSON.stringify({
    customerId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
    items: [
      { orderId: '00000000-0000-0000-0000-000000000000', productId: 'aaaa-...' },
      { orderId: '00000000-0000-0000-0000-000000000000', productId: 'bbbb-...' }
    ]
  })
})
```

**Response:**
```json
{
  "isSuccess": true,
  "data": {
    "id": "order-guid",
    "customerId": "customer-guid",
    "customer": { "id": "...", "name": "Trần Thị B", "phoneNumber": "0987..." },
    "totalAmount": 30000,
    "itemCount": 2,
    "items": [
      { "id": "item-guid", "productId": "...", "productName": "Coca Cola", "unitPrice": 15000 }
    ]
  }
}
```

---

### 7.2 Danh sách đơn hàng (phân trang)

```
GET /api/v1/orders
```

| filter field | Type | Mô tả |
|---|---|---|
| `customerId` | guid | Lọc theo khách hàng |
| `fromDate` | datetime | Từ ngày (ISO 8601) |
| `toDate` | datetime | Đến ngày |

```js
const filter = encodeURIComponent(JSON.stringify({
  fromDate: '2024-01-01T00:00:00Z',
  toDate: '2024-01-31T23:59:59Z'
}));
fetch(`http://localhost:8089/api/v1/orders?filter=${filter}`, {
  headers: { 'Authorization': `Bearer ${TOKEN}` }
})
```

---

### 7.3 Chi tiết / Cập nhật / Xóa đơn hàng

```
GET    /api/v1/orders/{id}
PUT    /api/v1/orders/{id}
DELETE /api/v1/orders/{id}
```

---

### 7.4 Thống kê sản phẩm đã bán

```
GET /api/v1/orders/statistics/sold-products
```

| filter field | Type | Mô tả |
|---|---|---|
| `fromDate` | datetime | Từ ngày |
| `toDate` | datetime | Đến ngày |

```js
const filter = encodeURIComponent(JSON.stringify({
  fromDate: '2024-01-01T00:00:00Z',
  toDate: '2024-12-31T23:59:59Z'
}));
fetch(`http://localhost:8089/api/v1/orders/statistics/sold-products?filter=${filter}`, {
  headers: { 'Authorization': `Bearer ${TOKEN}` }
})
// Response: [{ productId, productName, quantitySold, totalRevenue }]
```

---

### 7.5 Thống kê doanh thu theo sản phẩm

```
GET /api/v1/orders/statistics/revenue-by-product
```

| filter field | Type | Mô tả |
|---|---|---|
| `productName` | string | Tìm kiếm theo tên |
| `fromDate` | datetime | Từ ngày |
| `toDate` | datetime | Đến ngày |

---

## 8. Order Items – Chi tiết đơn hàng

> Tất cả endpoint đều yêu cầu 🔒 Bearer Token

### 8.1 Tạo order item

```
POST /api/v1/order-items
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `orderId` | guid | ✅ | ID đơn hàng |
| `productId` | guid | ✅ | ID sản phẩm |

---

### 8.2 CRUD Order Items

```
GET    /api/v1/order-items      ← filter: orderId, productId, fromDate, toDate
GET    /api/v1/order-items/{id}
PUT    /api/v1/order-items/{id}
DELETE /api/v1/order-items/{id}
```

---

## 9. Product Price History – Lịch sử giá

> Tất cả endpoint đều yêu cầu 🔒 Bearer Token

### 9.1 Tạo bản ghi giá

```
POST /api/v1/product-price-histories
```

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `productId` | guid | ✅ | ID sản phẩm |
| `price` | decimal | ✅ | Giá áp dụng |
| `effectiveFromDate` | datetime | ✅ | Ngày bắt đầu |
| `effectiveToDate` | datetime | | Ngày kết thúc (`null` = đang áp dụng) |

```js
fetch('http://localhost:8089/api/v1/product-price-histories', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TOKEN}`
  },
  body: JSON.stringify({
    productId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
    price: 18000,
    effectiveFromDate: '2024-03-01T00:00:00Z',
    effectiveToDate: null
  })
})
```

---

### 9.2 CRUD Price History

```
GET    /api/v1/product-price-histories      ← filter: productId
GET    /api/v1/product-price-histories/{id}
PUT    /api/v1/product-price-histories/{id}
DELETE /api/v1/product-price-histories/{id}
```

---

## 10. IDM – Quản lý người dùng & phân quyền

### 10.1 User Management

> Base path: `/api/v1/idm/users` | 🔒 Bearer Token

```
POST   /api/v1/idm/users              ← Tạo user (Admin only)
GET    /api/v1/idm/users              ← Danh sách (phân trang)
PUT    /api/v1/idm/users/{id}         ← Cập nhật thông tin
DELETE /api/v1/idm/users/{id}         ← Xóa user (Admin only)
GET    /api/v1/idm/users/checkname/{name}  ← Kiểm tra username còn khả dụng không
```

**Request body tạo user:**

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `userName` | string | | Username |
| `name` | string | ✅ | Họ tên |
| `phoneNumber` | string | ✅ | 10 chữ số |
| `email` | string | | Email |
| `password` | string | ✅ | Mật khẩu |
| `gender` | int | | `0`=Unknown, `1`=Male, `2`=Female |
| `isActive` | bool | | Kích hoạt tài khoản |
| `roleListCode` | string[] | | Danh sách role code VD: `["ADMIN"]` |

---

### 10.2 Role Management

> Base path: `/api/v1/idm/roles` | 🔒 Bearer Token

```
POST   /api/v1/idm/roles              ← Tạo nhóm quyền
GET    /api/v1/idm/roles              ← Danh sách (phân trang)
GET    /api/v1/idm/roles/all          ← Lấy tất cả (không phân trang)
GET    /api/v1/idm/roles/{id}         ← Chi tiết
GET    /api/v1/idm/roles/{id}/detail  ← Chi tiết + quyền liên kết
PUT    /api/v1/idm/roles/{id}         ← Cập nhật
DELETE /api/v1/idm/roles/{id}         ← Xóa một
DELETE /api/v1/idm/roles              ← Xóa nhiều (body: [guid, guid, ...])
```

---

### 10.3 Right Management

> Base path: `/api/v1/idm/rights` | 🔒 Bearer Token

```
POST   /api/v1/idm/rights             ← Tạo quyền
GET    /api/v1/idm/rights             ← Danh sách (phân trang)
GET    /api/v1/idm/rights/all         ← Lấy tất cả
GET    /api/v1/idm/rights/{id}        ← Chi tiết
PUT    /api/v1/idm/rights?id={id}     ← Cập nhật
DELETE /api/v1/idm/rights?id={id}     ← Xóa
POST   /api/v1/idm/rights/seed        ← Seed quyền hàng loạt (?groupCode=...&groupName=...)
```

---

### 10.4 Right Map Role – Gán quyền vào nhóm

> Base path: `/api/v1/idm/right-map-role` | 🔒 Bearer Token

```
POST   /api/v1/idm/right-map-role           ← Gán quyền vào nhóm
DELETE /api/v1/idm/right-map-role           ← Gỡ quyền khỏi nhóm
GET    /api/v1/idm/right-map-role/{roleId}  ← Lấy danh sách quyền trong nhóm
```

**Request body (POST / DELETE):**

| Field | Type | Required | Mô tả |
|---|---|---|---|
| `roleId` | guid | ✅ | ID nhóm quyền |
| `rightIds` | guid[] | ✅ | Danh sách ID quyền |

```js
// Gán quyền
fetch('http://localhost:8089/api/v1/idm/right-map-role', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${TOKEN}`
  },
  body: JSON.stringify({
    roleId: 'role-guid',
    rightIds: ['right-guid-1', 'right-guid-2']
  })
})
```

---

## 11. Cấu trúc Response chung

```json
// Thành công – single item
{
  "isSuccess": true,
  "message": "...",
  "data": { }
}

// Thành công – danh sách phân trang
{
  "isSuccess": true,
  "data": {
    "items": [ ],
    "totalCount": 100,
    "page": 1,
    "size": 20,
    "totalPages": 5
  }
}

// Lỗi
{
  "isSuccess": false,
  "message": "Mô tả lỗi",
  "data": null
}
```

**HTTP Status Codes:**

| Code | Ý nghĩa |
|---|---|
| `200` | Thành công |
| `201` | Tạo mới thành công |
| `400` | Dữ liệu đầu vào không hợp lệ |
| `401` | Thiếu hoặc sai token |
| `403` | Không có quyền truy cập |
| `404` | Không tìm thấy bản ghi |
| `500` | Lỗi máy chủ nội bộ |

---

## 12. Quick Start – Luồng hoàn chỉnh

> Đăng nhập → Tạo danh mục → Tạo sản phẩm → Tạo khách hàng → Tạo đơn hàng → Xem thống kê

```js
const BASE = 'http://localhost:8089/api/v1';

// 1. Đăng nhập
const loginRes = await fetch(`${BASE}/authentication/jwt/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ phoneNumber: '0901234567', password: '123456' })
});
const { data: { tokenString: TOKEN } } = await loginRes.json();
const H = { 'Content-Type': 'application/json', 'Authorization': `Bearer ${TOKEN}` };

// 2. Tạo danh mục
const cat = await fetch(`${BASE}/categories`, {
  method: 'POST', headers: H,
  body: JSON.stringify({ name: 'Đồ uống', description: 'Nước giải khát' })
}).then(r => r.json());
const categoryId = cat.data.id;

// 3. Tạo sản phẩm
const prod = await fetch(`${BASE}/products`, {
  method: 'POST', headers: H,
  body: JSON.stringify({ name: 'Coca Cola', categoryId, currentPrice: 15000, stockQuantity: 100 })
}).then(r => r.json());
const productId = prod.data.id;

// 4. Tạo khách hàng
const cust = await fetch(`${BASE}/customers`, {
  method: 'POST', headers: H,
  body: JSON.stringify({ name: 'Nguyễn Văn A', phoneNumber: '0987654321' })
}).then(r => r.json());
const customerId = cust.data.id;

// 5. Tạo đơn hàng
const order = await fetch(`${BASE}/orders`, {
  method: 'POST', headers: H,
  body: JSON.stringify({
    customerId,
    items: [{ orderId: '00000000-0000-0000-0000-000000000000', productId }]
  })
}).then(r => r.json());

console.log('Đơn hàng:', order.data.id, '| Tổng tiền:', order.data.totalAmount);

// 6. Thống kê sản phẩm bán được
const stats = await fetch(`${BASE}/orders/statistics/sold-products`, {
  headers: H
}).then(r => r.json());

console.log('Thống kê:', stats.data);
```

---

*— End of Document —*

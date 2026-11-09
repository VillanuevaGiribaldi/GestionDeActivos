export type  loginResponse= {
    mensaje: string;
    token: string;
    usuario: JSON;
}


/*

{
  "mensaje": "Autenticación exitosa",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sIjoiQURNSU5fSVQiLCJpYXQiOjE3OTQyNTU2NzMsImV4cCI6MTgyNTc5MTY3M30.a_0NFvWVJvB9E9DFageZdwg-3cdhlkWZ8fBErk-R1AY",
  "usuario": {
    "id": 1,
    "username": "jperez",
    "rol": "ADMIN_IT"
  }
}*/
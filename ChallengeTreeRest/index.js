require('dotenv').config()
const express = require('express')
const cors = require('cors');

const app = express()
const bodyParser = require('body-parser')
const pet = require("./routes/pet")

app.use(cors())
app.use(bodyParser.json({ limit: '1gb' }));
app.use(bodyParser.urlencoded({ limit: '1gb', extended: true }));
app.use(express.json({ limit: '1gb' }));
app.use("/v1/pets", pet)



app.listen(process.env.PORT, () => {
    console.log(`Server its runnig in the port ${process.env.PORT} `)
})
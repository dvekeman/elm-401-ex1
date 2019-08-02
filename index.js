const express = require('express')
const request = require('request');
const app = express()
const port = 8000

app.use(express.static('public'))

app.get('/auth/success', (req, res) => {
    msg =
        {
            message: 'Welcome!',
            authenticated: true
        }
    res.status(200).send(JSON.stringify(msg))
})

app.get('/auth/failed', (req, res) => {
    res.status(401).send("Unauthenticated")
})

app.get('/auth/restricted-area', (req, res) => {
    res.status(403).send("Unauthorized")
})

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
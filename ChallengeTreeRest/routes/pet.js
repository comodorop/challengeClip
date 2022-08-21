const express = require('express')
const routes = express.Router()
const { save, get } = require('../services/pet.services')

routes.post('/', async (req, res) => {
    try {
        let { body } = req
        let data = await save(body, "pet")
        res.status(200).send({ msg: "New record valiabled" })
    } catch (error) {
        console.log(error)
        res.status(500).send({ msg: "There is a problem" })
    }
})

routes.get('/:name', async (req, res) => {
    try {
        let { name } = req.params
        let data = await get("pet", name)
        if (data.length === 0) {
            res.status(404).send({ msg: "Pet not found" })
        } else {
            res.status(200).send({ data: data })
        }
    } catch (error) {
        res.status(500).send({ msg: "There is a problem" })
    }
})


module.exports = routes
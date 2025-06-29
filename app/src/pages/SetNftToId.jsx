import React, { useState } from "react";
import {useParams, useNavigate} from 'react-router-dom'
import {Form, Button} from 'react-bootstrap'

export default function SetNftToId(props) {

    const params = useParams()
    const router = useNavigate()


    const [nft, setNft] = useState({name: '', desc: '', file: '', amount: ''})

    const file = (e) => {
        setNft({...nft, file: e.target.files[0].name})
        console.log(nft)
    }

    const set = async (e) => {
        e.preventDefault()

        try {
            const res = await props.contract.connect(props.signer).setNftInCollection(
                Number(params.id),
                nft.name,
                nft.desc,
                nft.file,
                nft.amount
            )
            console.log(res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
            router('/lk')
        } catch(err) {
            console.log(err)
            alert(err)
        }

    }


    const [action, setAction] = useState({start: 0, end: 0, min: 0, max: 0})

    const create = async (e) => {
        e.preventDefault()

        let s = new Date(action.start)
        let en = new Date(action.end)

        try {
            const res = await props.contract.connect(props.signer).setAction(
                Number(params.id),
                s.getTime(),
                en.getTime(),
                action.min,
                action.max
            )
            console.log(res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
            router('/lk')
        } catch(err) {
            alert(err)
        }
    }
    

    return (
        <div style={{ display: 'flex', gridGap: '25%', margin: '200px', alignItems: 'center'}}>
            <div>
                <h1>Добавить nft в выбранную коллекцию</h1>
                <Form onSubmit={set} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center'}}>
                    <Form.Group>
                        <Form.Control type="text"  value={nft.name} onChange={e => setNft({...nft, name: e.target.value})} style={{width: '500px'}} placeholder="введите название" required />
                        <Form.Control type="text"  value={nft.desc} onChange={e => setNft({...nft, desc: e.target.value})} style={{width: '500px'}} placeholder="введите описание" required />
                        <Form.Control type="number" min={1}  value={nft.amount} onChange={e => setNft({...nft, amount: e.target.value})} style={{width: '500px'}} placeholder="введите количество" required />
                        <Form.Control type="file" onChange={file} required />
                    </Form.Group>

                    <Button type="submit" style={{margin: '15px', width: '300px'}}>добавить</Button>
                </Form>
            </div>

            <div>
                <h1>Создать аукцион</h1>
                <Form onSubmit={create} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center'}}>
                    <Form.Group>
                        <Form.Control type="datetime-local"  value={action.start} onChange={e => setAction({...action, start: e.target.value})} style={{width: '500px'}} title="введите дату начала" required />
                        <Form.Control type="datetime-local"  value={action.end} onChange={e => setAction({...action, end: e.target.value})} style={{width: '500px'}} title="введите дату окончания" required />
                        <Form.Control type="number" min={1}  value={action.min} onChange={e => setAction({...action, min: e.target.value})} style={{width: '500px'}} title="введите минимальную стоимость" required />
                        <Form.Control type="number" min={1}  value={action.max} onChange={e => setAction({...action, max: e.target.value})} style={{width: '500px'}} title="введите максимальную стоимость" required />
                    </Form.Group>

                    <Button type="submit" style={{margin: '15px', width: '300px'}}>добавить</Button>
                </Form>
            </div>
        </div>
    )
}
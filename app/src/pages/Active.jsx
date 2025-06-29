import React, { useEffect, useState } from "react";
import Nft from "./Nft";

export default function Active(props) {

    const [nft, setNft] = useState(null)
    const [action, setAction] = useState(null)

    useEffect(() => {
        const interval = setInterval(async () => {
            let n = await props.contract.connect(props.signer).getSellNft()
            setNft(n)
            
            let a = await props.contract.connect(props.signer).getAcrion()
            setAction(a)
        })

        return () => {
            clearInterval(interval)
        }
    }, [])


    return (
        <div style={{display: 'flex', gridGap: '50%'}}>
            <div>
                <h1>Одиночные nft</h1>
                {nft 
                    ?
                        <div>
                            {nft.map(n => 
                                <Nft nft={n} lk={false} signer={props.signer} contract={props.contract}></Nft>
                            )}
                        </div>
                    :
                        <p>Пока тут пусто</p>
                }
            </div>

            <div>
                <h1>Аукционы</h1>
                {action
                    ?
                       <div>
                            {action.map(a => 
                                <div>
                                    <h4>Аукцион {a[0].toString()}</h4>
                                    <p>Название коллекции: {a[1][1]}</p>
                                    <p>Описание коллекции: {a[1][2]}</p>
                                    <p>id nft в коллекции: {a[1][3].toString()}</p>
                                    <p>Время начала: {a[2].toString()}</p>
                                    <p>Время завершения: {a[3].toString()}</p>
                                    <p>Минимальная ставка: {a[4].toString()}</p>
                                    <p>Максимальная ставка: {a[5].toString()}</p>
                                </div>
                            )}
                       </div>
                    :
                        <p>Пока тут пусто</p>
                }
            </div>
        </div>
    )
}
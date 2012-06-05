Twitbox
======================
コンソール画面で Twitter のタイムラインを流します。    
フルスクリーンでターミナル開いて作業してるときにタイムラインが気になる紳士淑女のためのツールです。

準備
------
  ``gem install oauth``  
  ``gem install term-ansicolor``  
  tokens.txt.sample みたいな感じで tokens.txt を作ってください。

実行
------
  タイムラインを表示する ``ruby timeline.rb``  
  ターミナルで別ペインを使って呟いたり色々（開発中） ``ruby inp.rb``  
    ``post Hello`` => Hello って呟く  
    ``post 123456789012345678 Hello`` => Hello ってリプする  
    ``fav 123456789012345678`` => ふぁぼる  
    ``RT 123456789012345678`` => 公式 RT する  
    ``del 123456789012345678`` => 発言または公式 RT を取り消す  
    ``exit`` => 終了する  

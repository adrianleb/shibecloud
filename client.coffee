# @cjsx React.DOM

Array::diff = (a) ->
  @filter (i) ->
    a.indexOf(i) < 0



React       = require("react")
ReactAsync  = require("react-async")
ReactRouter = require("react-router-component")
superagent  = require("superagent")
NotFoundHandler = require("./components/notfound.coffee")

Pages       = ReactRouter.Pages
Page        = ReactRouter.Page
NotFound    = ReactRouter.NotFound
Link        = ReactRouter.Link












Menu = React.createClass
  getInitialState: ->
    searchOpen: true

  toggleInput: ->
    @setState searchOpen: !@state.searchOpen

  onSubmit: (e) ->
    e.preventDefault()

    @props.parseSoundcloud(@refs.urlVal.getDOMNode().value)
  render: ->
    <div className="menu #{if @props.menuOpen then 'visible' else ''}">
        <h2>Shibecloud exalts the best out of the comments on your soundcloud track by displaying them in a way it can be better understood and appreciated, dogefied.</h2>
        <div id="track-url" className="input_url #{if @state.searchOpen then 'visible' else ''}">
          <h3>Place a soundcloud track url below, the more comments the merrier. </h3>
          <form onSubmit={@onSubmit}>
            <input type="text" id="track-form-input" ref="urlVal" placeholder="Ex.: https://soundcloud.com/disclosuremusic/apollo"/>
            <input type="submit" value="shibecloud it"/>
          </form>
        </div>
        <p>A thing by <a href="http://adrians.info" target="_blank">Adrian le Bas</a>   <br/>wow</p>

    </div>

























Track = React.createClass

  statics:
    requestComments: (uri, cb) ->
      key = "8e02b0157f78d50db5298810ca490d0f"
      url = uri + "/comments.json?client_id=#{key}"
      superagent.get url, (err, r) ->
        cb r.body

    getFaces: (uri, cb) =>
      fc = new FCClientJS "6a860fad4fd5411192059f443fd4585e", "f056b459346247e89742d4520607761d"
      b = fc.facesDetect uri, null, {}, (e, r, t) =>
        cb(e)
    
    dogefyText: (txt) ->
      txt = txt.replace('much', 'muhc')
              .replace('good', 'goed')
              .replace('god', 'doge')
              .replace('ing', 'e')
              .replace('love', 'much loev')
              .replace('great', 'greatness')
              .replace('thanks', 'so thankful')
              .replace('really', 'srsly')
              .replace('like', 'much liek')
              .replace('ed ', 'ered')
              .replace('music', 'muisicz')
              .replace('this', 'thsi')
              .replace('please', 'plzplz')
              .replace('better', 'bettah')
              .replace(' is ', " ")
              .replace(' an ', ' ')
              .replace('awesome', 'such awesome')
              .replace('nice', 'nisce')
    
      if (Math.random * 10) > 5
        txt = "WOW"

      return txt

  getInitialState: ->
    faces: []
    comments: []
    nextComments: []


  initCurrentTrack: ->
    @setState
      faces: []
      comments: []
      nextComments: []


    @type.getFaces @props.currentTrack.image, (e) =>
      newFaces = []

      if e.photos[0].tags.length
        for face in e.photos[0].tags
          face = {
            top: "#{face.center.y}%"
            left:"#{face.center.x}%"
            marginLeft: "-#{face.width * 1.65}%"
            marginTop:"-#{face.height * 1.55}%"
            paddingBottom:"#{face.height * 2.75}%"
            width:"#{face.width * 2.75}%"
          }
          newFaces.push face
      else
        newFaces.push {top:"80%", left: "80%", paddingBottom: "20rem"}

      @setState faces:newFaces


    @type.requestComments @props.currentTrack.uri, (r) =>
      colors = ['red', 'pink', 'lightgreen', 'green', 'yellow', 'orange', 'lightblue', 'violet', 'cyan', 'Chartreuse', 'azure']

      console.log r, 'res'
      comments = r.map (comment) =>
        return {
          id:comment.id
          timestamp:comment.timestamp
          body:@type.dogefyText(comment.body)
          top: "#{Math.random() * 100}%"
          left: "#{Math.random() * 100}%"
          color: colors[Math.round(Math.random() * 10)]
        }

      @setState comments: _.sortBy(comments, (a,b) => return a.timestamp - b.timestamp)

  


  updateTime: ->
    nextComments = @state.nextComments
    for com in @state.comments
      if com.timestamp < @props.currentTime
        if com.body.length < 70     
          nextComments.push com


    @setState 
      nextComments:nextComments
      comments: @state.comments.diff(nextComments)


  renderItem: (comment) ->
    console.log 'rendering?'
    visible = if ((comment.timestamp + 1000) < @props.currentTime) then '' else 'visible'

    return (<h4 className="comment #{visible}" key={comment.id} style={'top':comment.top, 'left':comment.left, 'color':comment.color} > {comment.body} </h4>)


  renderDoge: (face) ->
    return (<div className='doge' style={face}></div>)

  render: ->
    console.log @state.nextComments
    <div id="track" style={"background-image": "url(#{if @props.currentTrack then @props.currentTrack.image else ''})"}>
      {@state.faces.map(@renderDoge)}
      <div id="track-comments">
        {@state.nextComments.map(@renderItem)}
      </div>
    </div>





















Header = React.createClass
  render: ->
    nowPlaying = if @props.nowPlaying then "play" else "pause"
    <header>
      <h1>Shibecloud</h1>
      <a href="#" id="menu-toggle" onClick={@props.toggleMenu} className="menu_toggle"></a>
      <a href="#" id="play-toggle" onClick={@props.togglePlay} className="play_toggle #{nowPlaying}"></a>
    </header>

















MainPage = React.createClass

  statics:
    key: "8e02b0157f78d50db5298810ca490d0f"
    
    parseTrackUrl: (url, cb) ->
      superagent.get "http://api.soundcloud.com/resolve.json?url=#{url}&client_id=#{@key}", (err, r) =>
        unless r.status is 200
          return
        cb(r)


  getInitialState: ->
    coldPlayer: true
    nowPlaying: false
    trackUrl: null
    currentTrack: null
    menu: true


  componentDidMount: ->
    @audio = @refs.audioPlayer.getDOMNode()
    @audio.addEventListener "timeupdate", @updateTime
    @audio.addEventListener "ended", @handleEnded



  handleEnded: ->
    console.log 'track ended dud'

  updateTime: (e)->
    @setState currentTime: Math.round(@audio.currentTime * 1000)
    @refs.track.updateTime()

  toggleMenu: ->
    @setState 
      menu: !@state.menu

  togglePlay: ->
    newState = !@state.nowPlaying
    if newState then @audio.play() else @audio.pause()
    @setState nowPlaying: newState


  initTrack: (val) ->
    track_url = val

    @type.parseTrackUrl track_url, (r) =>
      track = {
        image: if r.body.artwork_url? then r.body.artwork_url.replace('large', 't500x500') else null
        title: r.body.title
        uri: r.body.uri
      }


      if track.uri

        @setState currentTrack: track
        @initCurrentTrack()


      


  initCurrentTrack: (t) ->
    @setState coldPlayer:false
    @setState menu:false

    @setState nowPlaying:true
    @refs.track.initCurrentTrack()

    # @play()




  currentTrackStream: ->
    url = ""
    if @state.currentTrack
      url = @state.currentTrack.uri + "/stream?client_id=#{@type.key}"
    return url


  render: ->
    <main id="main" className="#{if not @state.menu then 'menu_visible_off' else ''} #{if @state.coldPlayer then 'cold-player' else ''}">
      <div className="logo" />

      <Header toggleMenu={@toggleMenu} nowPlaying={@state.nowPlaying} togglePlay={@togglePlay}/>
      <Menu  parseSoundcloud={@initTrack}/>
        <div id="bg" style={"background-image": "url(#{if @state.currentTrack then @state.currentTrack.image else ''})"} ></div>
        <Track ref="track" currentTrack={@state.currentTrack} currentTime={@state.currentTime} comments={@state.comments} faces={@state.faces}/>
        <audio id="audio" autoPlay="true" src="#{@currentTrackStream()}" ref="audioPlayer"></audio>
    </main>








App = React.createClass
  render: ->
    <html>
      <head>
        <link rel="stylesheet" href="/assets/style.css" />

        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1 user-scalable=no"/>
        
        <script src="/assets/FCClientJS.js" />
        <script src="http://cdnjs.cloudflare.com/ajax/libs/lodash.js/2.4.1/lodash.min.js"/>
        <script src="/assets/bundle.js" />
      </head>
      <Pages className="App" path={@props.path}>
        <Page path="/" handler={MainPage} />
        <NotFound handler={NotFoundHandler} />
      </Pages>
    </html>

module.exports = App;

if typeof window isnt "undefined"
  window.onload = ->
    React.renderComponent App(), document
RequestFormatter = require '../src/models/request-formatter'

describe 'RequestFormatter', ->
  beforeEach ->
    @sut = new RequestFormatter

  describe '->setting params', ->
    describe 'bodyParams', ->
      describe 'when called with an config', ->
        it 'should return the message', ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            bodyParams:
              'going.deep': 'foo'

          expect(@sut.format config).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            form:
              going:
                deep: 'foo'
            method: "PATCH"
            qs: {}
          )


    describe 'bodyParams with hidden parameters', ->
      describe 'when called with an config', ->
        it 'should return the message', ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            bodyParams:
              'going.deep': 'foo'
            hiddenParams: [
              name: 'super.secret'
              value: 'agent'
              style: 'body'
            ]

          expect(@sut.format config).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            form:
              going:
                deep: 'foo'
              super:
                secret: 'agent'
            method: "PATCH"
            qs: {}
          )

    describe 'querystring with hidden parameters', ->
      describe 'when called with an config', ->
        it 'should return the message', ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            queryParams:
              'drill.to.the.core': 'foo'
            hiddenParams: [
              name: 'drill.to.the.moon'
              value: 'moonman'
              style: 'query'
            ]

          expect(@sut.format config).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            form: {}
            method: "PATCH"
            qs:
              drill:
                to:
                  the:
                    core: 'foo'
                    moon: 'moonman'
          )

  describe '->format', ->
    describe 'NoAuthStrategy', ->
      describe 'when called with an config', ->
        it 'should return the message', ->
          config =
            url: "ad.ams"
            method: 'PATCH'

          expect(@sut.format config).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
          )

    describe 'BasicAuthStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              access_token: 'something'
              access_token_secret: 'to-dig-with'
              tokenMethod: 'basic'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
            auth:
              username: 'something'
              password: 'to-dig-with'
          )

    describe 'AccessTokenBearerStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              access_token: 'something-with-5000-calories'
              tokenMethod: 'access_token_bearer'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
            auth:
              bearer: 'something-with-5000-calories'
          )

    describe 'AccessTokenQueryStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              tokenMethod: 'access_token_query'
              access_token: 'old-well'
              tokenQueryParam: 'korean-water-ghost'
            queryParams:
              'impaled-through-the-chest': 'bar'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs:
              'korean-water-ghost': 'old-well'
              'impaled-through-the-chest': 'bar'
          )

    describe 'AccessTokenBearerAndApiKeyStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              tokenMethod: 'access_token_bearer_and_api_key'
              access_token: 'magical-wish-granting-orb'
              api_key: 'infinite-wishes'
            queryParams:
              '1-billion-in-pennies': 'space-alligator-portal'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            auth:
              bearer: 'magical-wish-granting-orb'
            form: {}
            qs:
              'api_key': 'infinite-wishes'
              '1-billion-in-pennies': 'space-alligator-portal'
          )

    describe 'SignedOAuthStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              tokenMethod: 'oauth_signed'
              key: 'candy'
              secret: 'a-lollipop'
              access_token: 'gushers'
              access_token_secret: 'candy-corn'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
            oauth:
              consumer_key: 'candy'
              consumer_secret: 'a-lollipop'
              token: 'gushers'
              token_secret: 'candy-corn'
          )

    describe 'HeaderApiKeyAuthStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              tokenMethod: 'header'
              headerParam: 'smartphone'
              access_token: 'a-screened-item'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "smartphone": 'a-screened-item'
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
          )

    describe 'AuthTokenStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            oauth:
              tokenMethod: 'auth_token'
              tokenQueryParam: 'robe-of-power'
              access_token: 'hefnerian-smoking-jacket'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              "Authorization": 'robe-of-power hefnerian-smoking-jacket'
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
          )

    describe 'ApiKeyStrategy', ->
      describe 'when called with an config', ->
        beforeEach ->
          config =
            url: "ad.ams"
            method: 'PATCH'
            authHeaderKey: 'allergy'
            apikey: 'near-future-plant-fertilizer'
            oauth:
              tokenMethod: 'apikey'

          @result = @sut.format config

        it 'should return the message', ->
          expect(@result).to.deep.equal(
            uri: "ad.ams"
            followAllRedirects: true
            headers:
              'allergy': 'near-future-plant-fertilizer'
              "Accept": "application/json"
              "User-Agent": "Octoblu/1.0.0"
              "x-li-format": "json"
            method: "PATCH"
            form: {}
            qs: {}
          )

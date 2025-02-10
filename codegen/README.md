codegen
=======

> A util tool to generate a client from the Swagger spec of Nakama's server API.

## Usage

If you have cloned [nakama](https://github.com/heroiclabs/nakama) repo locally:

```shell
go run main.go --output ../addons/com.heroiclabs.nakama/api/NakamaAPI.gd "$GOPATH/src/github.com/heroiclabs/nakama/apigrpc/apigrpc.swagger.json" Nakama
```

If you don't have nakama repo locally, a required file can be fetched from github:

```shell
go run main.go --output ../addons/com.heroiclabs.nakama/api/NakamaAPI.gd "https://raw.githubusercontent.com/heroiclabs/nakama/master/apigrpc/apigrpc.swagger.json" Nakama
```

### Rationale

We want to maintain a simple lean low level client within our GDScript client which has minimal dependencies so we built our own. This gives us complete control over the dependencies required and structure of the code generated.

The generated code is designed to support Godot Engine `4.0+`.

### Limitations

The code generator has __only__ been checked against the Swagger specification generated for Nakama server. YMMV.


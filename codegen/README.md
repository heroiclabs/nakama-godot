codegen
=======

> A util tool to generate a client from the Swagger spec of Nakama's server API.

## Usage

```shell
go run main.go "$GOPATH/src/github.com/heroiclabs/nakama/apigrpc/apigrpc.swagger.json" > ../addons/com.heroiclabs.nakama/api/NakamaAPI.gd
```

### Rationale

We want to maintain a simple lean low level client within our GDScript client which has minimal dependencies so we built our own. This gives us complete control over the dependencies required and structure of the code generated.

The generated code is designed to be supported Godot Engine `3.1+`.

### Limitations

The code generator has __only__ been checked against the Swagger specification generated for Nakama server. YMMV.


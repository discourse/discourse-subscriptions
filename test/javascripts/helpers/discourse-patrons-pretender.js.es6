
export default function(helpers) {
  const { response } = helpers;

  this.get("/patrons", () => response({ email: "hello@example.com" }))
}

Swimmer = Class {
  init = function (self, parentManager, image)
    self.parentManager = parentManager;
    self.image = image;

    self.type = "swimmer";
    self.active = true;
  end
}

function Swimmer:update(dt)
  if not self.active then
    return;
  end


end

function Swimmer:draw()

end
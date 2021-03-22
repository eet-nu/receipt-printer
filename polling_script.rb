require_relative 'print/lib/print_receipts'

while true do
  PrintReceipts.fetch_and_print
  sleep(2)
end
